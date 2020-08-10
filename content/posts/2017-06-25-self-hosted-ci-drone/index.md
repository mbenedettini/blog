---
title: >-
  Self-hosted solution: development pipeline with Drone CI
author: Mariano Benedettini
date: 2017-06-25
hero: 
excerpt: >-
  Deploying a self hosted CI (Drone CI) that publishes the image to a Docker registry 
---

In one of my projects I’ve come across the need to build Docker images in some hosted service: I want to push changes to the remote repository and know that in a few minutes an updated Docker image will be available somewhere. That was the goal of the latest improvements I’ve made to this project.

To have a Docker image “available somewhere” means that you have to push it to some [Docker registry](https://docs.docker.com/registry/) which is anything else than a repository containing Docker images.


I don’t want to spend time on my laptop waiting for an image to be built, so building them locally and then pushing to a remote Docker registry (you can easily set up an [Amazon Container Registry](https://aws.amazon.com/ecr/) if you only want that) is not an option. A good companion for it is Travis CI, which is really great and I have used it a lot, but it’s [painfully expensive](https://travis-ci.com/plans), specially if you just want to build a side project.

For the registry, the solution was clear: [Docker distribution](https://github.com/docker/distribution). Now, when it came to the CI Server I had to decide between Strider and Drone. I’ve had not-so-great experiences with Jenkins in the past so I decided to try something new. In the end I chose Drone, after a quick evaluation of codebase, docs and examples.

Registry was up and running quite smoothly. The only thing I had to manually do was creating users, which are then used to login to the registry with `docker login`. That is well documented on this article: https://docs.docker.com/registry/deploying/#native-basic-auth .

Now it’s been 2 months of happy building and deploying via Drone which has proven to be simple, flexible and powerful. All of them run within the same docker-compose environment. Installation of Drone can be done following the guide at http://readme.drone.io/admin/installation-guide/and the `docker-compose.yml` I ended up with is based on the one here:


#### **`docker-compose.yml`**
```yaml
# Docker registry (distribution) + Drone 0.5
version: '2'

services:
  registry-srv:
    restart: always
    image: registry:2
    environment:
      - VIRTUAL_HOST=registry.codexia.io
      - VIRTUAL_PORT=5000
      - LETSENCRYPT_HOST=registry.codexia.io
      - LETSENCRYPT_EMAIL=mariano@codexia.io
      # Make nginx-proy use ssl, required to have basic auth
      - VIRTUAL_PROTO=https
      - REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.codexia.io.crt
      - REGISTRY_HTTP_TLS_KEY=/certs/registry.codexia.io.key
      - REGISTRY_AUTH=htpasswd
      - REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd
      - REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm
    volumes:
      - /storage/registry/data:/var/lib/registry
      - /storage/nginx-proxy/certs:/certs
      - /storage/registry/auth:/auth

  drone-server:
    image: drone/drone:0.5
    volumes:
      - /storage/drone:/var/lib/drone/
    restart: always
    env_file: .env
    environment:
      - VIRTUAL_HOST=drone.codexia.io
      - VIRTUAL_PORT=8000
      - LETSENCRYPT_HOST=drone.codexia.io
      - LETSENCRYPT_EMAIL=mariano@codexia.io
      - DRONE_OPEN=true
      - DRONE_BITBUCKET=true
      - DRONE_ADMIN=mbenedettini
      - GIN_MODE=release

  drone-agent:
    image: drone/drone:0.5
    command: agent
    restart: always
    depends_on: [ drone-server ]
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    env_file: .env
    environment:
      - DRONE_SERVER=ws://drone-server:8000/ws/broker
      - GIN_MODE=release

networks:
  default:
    external:
      name: nginx-proxy
```

`.env` contains of course environment variables with secret values such as Bitbucket credentials ( `DRONE_BITBUCKET_CLIENT` and `DRONE_BITBUCKET_SECRET` ).


Their [admin documentation](http://readme.drone.io/admin/) is quite good and there you will find answer to most of your questions, such as [how to setup Bitbucket integration](http://readme.drone.io/admin/setup-bitbucket/) (yeah, most of my projects are hosted there 🙂 ).

As you can see, all of those services are visible from the Internet and encrypted by Letsencrypt certificates thanks to [nginx-proxy](https://github.com/jwilder/nginx-proxy) and [docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion), of which I have already talked about [here](https://marianobe.com/a-simple-approach-to-host-multiple-docker-container-in-a-production-environment).

The real power of Drone lies on its [plugins](http://plugins.drone.io/). Literally a build pipeline capable of almost anything can be created with them. Let’s get started, first of all you have to introduce a drone.yml file into your project’s repository, according to its [user guide](http://readme.drone.io/usage/getting-started/). This example has been taken from an actual project, and the pipeline changes for staging -develop branch- and production -master branch- environments. Staging just runs docker-compose and production is based on [Docker Swarm](https://docs.docker.com/engine/swarm/), which I manage with the help of [Portainer](http://portainer.io/).


#### **`.drone.yml`**
```yaml
branches:
  - [master, develop]

pipeline:
  build:
    image: docker:latest
    environment:
      - REGISTRY_USERNAME=${REGISTRY_USERNAME}
      - REGISTRY_PASSWORD=${REGISTRY_PASSWORD}
      - NODE_ENV=production
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    commands:
      - docker build -t myregistry.codexia.io/myproject -f Dockerfile-prod .
      - docker login -u "$REGISTRY_USERNAME" -p "$REGISTRY_PASSWORD" https://myregistry.codexia.io
      - docker push myregistry.codexia.io/myproject

  scp:
    # update docker-compose files
    when:
      branch: develop
    image: appleboy/drone-scp
    host: anotherhostname
    username: irtextranet
    key: ${DEPLOY_KEY}
    source:
      - docker-compose.yml
      - docker-compose.prod.yml
    target:
      - /home/irtextranet

  ssh:
    # Pull images and issue the required commands to deploy
    when:
      branch: develop
    image: appleboy/drone-ssh
    host: 10.2.169.197
    username: myproject
    key: ${DEPLOY_KEY}
    port: 22
    script:
      - /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull && /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.prod.yml down && /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --force-recreate && /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.prod.yml exec -T server npm run migrate up

  ssh:
    # Production environment is Swarm-based
    when:
      branch: master
    image: appleboy/drone-ssh
    host: myprojecthost.codexia.io
    username: drone-deploy
    key: ${DEPLOY_KEY_PROD}
    port: 22
    script:
      - sudo docker service update myproject-worker --image registry.codexia.io/myproject:latest
      - sudo docker service update myproject-server --image registry.codexia.io/myproject:latest

  notify:
    image: drillster/drone-email
    host: smtp.mailgun.org
    username: ${SMTP_USERNAME}
    password: ${SMTP_PASSWORD}
    from: drone@codexia.io
    recipients: [ mariano@codexia.io ]
    when:
      status: [ success, changed, failure ]
```

There are a couple of caveats to get along with Drone: one is remember to always sign drone.yml after making changes to it: http://readme.drone.io/cli/drone-sign/ . The other is [Drone secrets](http://readme.drone.io/0.5/usage/secrets/): a feature to store sensitive information such as passwords, deploy keys, etc., which can be used in a Drone file anytime during the build pipeline. In my example I use Drone secrets to store Mailgun credentials and ssh keys for remote servers.

Without any doubt I can say that [Drone ssh](http://plugins.drone.io/appleboy/drone-ssh/) is by far the most used plugin in my pipelines. It allows you to execute any set of commands on any remote server. And the private ssh key is securely stored by Drone secrets. As you can see in my example, I have used it to deploy the recently built image in both staging and production environments. You might have noticed that migrations are not explicitly run when deploying production, that’s because I’ve taken a different approach there and they are run when npm start is issued (the following line has been taken from `package.json`):

```
"start": "node node_modules/db-migrate/bin/db-migrate --config server/migrate-database.json up && node .",
```

You can read more about how I solved migrations for LoopbackJS projects in [this article](https://marianobe.com/postgres-migrations-in-loopback-v2).

To wrap it up: I’m so happy with this setup that right now I’m planning to upgrade my Drone instance to its latest version 0.7. Yes, it might not be as powerful or full featured as Travis, but it’s quite flexible, easy to configure and I love to host all of the services involved in my development workflow.

Thoughts? Would you like me to write more details about any of the tools or the setup described in this article? Please leave your comment!
