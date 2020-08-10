---
title: A simple approach to host multiple Docker container in a production environment
author: Mariano Benedettini
date: 2017-02-26
hero: 
excerpt: >-
  Compose, nginx-proxy. As simple as possible for a small/personal production environment. 
---

We already know the benefits of using Docker for our development environments (easy to install, reproduce, maintain, etc), but what about trying it on a production environment?

Without worrying too much about high availability and scaling (which would require something like Kubernetes or Docker swarm, of which I will probably write about later) we can quickly have Docker containers orchestrated with Docker Compose exposed to the internet with a FQDN, perfectly suitable for a staging environment, a simple WordPress site or even a full e-mail solution such as [Poste.io](https://poste.io/) .

With the help of [nginx-proxy](https://github.com/jwilder/nginx-proxy) we can easily expose the http/https service of several containers, all of them running in the same Docker engine. It’s nothing more than an automated way of maintaining an Nginx reverse proxy according to the containers currently running.

First of all we’re going to clone it:

`$ git clone https://github.com/jwilder/nginx-proxy`

The project already comes with a docker-compose.yml that I’d rather not touch. I’ve added instead an [override file](https://docs.docker.com/compose/extends/) named docker-compose.prod.yml which extends the original and allows us to redefine a couple of important things:


#### **`docker-compose.prod.yml`**
```yaml
version: '2'
  services:
    nginx-proxy:
      ports:
        - "443:443"
      volumes:
        - /storage/nginx-proxy/certs:/etc/nginx/certs
        - /storage/nginx-proxy/vhost.d:/etc/nginx/vhost.d:ro

networks:
  default:
    external:
      name: nginx-proxy
```



The first volume will contain the ssl certs needed to expose each https site. The second one will hold specific configuration files for each site that requires it. We’ll get to that soon.

Nginx proxy will query the Docker engine API and expose every container with a defined VIRTUAL_HOST environment variable, and if the port exposed by the container is not 80 you can override that with VIRTUAL_PORT.

For example, this is how it looks  a Compose file which runs a WordPress instance along with its database:



#### **`docker-compose.yml`**
```yaml
version: '2'

services:
  db:
     image: mariadb
     volumes:
       - /storage/example/db:/var/lib/mysql
     restart: always
     env_file: .env
     environment:
       - MYSQL_DATABASE=wordpress
       - MYSQL_USER=wordpress
       
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    links:
      - db
    restart: always
    volumes:
      - /storage/example/wp-content:/var/www/html/wp-content
    env_file: .env
    environment:
      - VIRTUAL_HOST=example.codexia.io
      - WORDPRESS_DB_USER=wordpress
      - WORDPRESS_DB_HOST=db:3306

networks:
  default:
    external:
      name: nginx-proxy

```

(The rest of the environment variables, such as MYSQL_ROOT_PASSWORD, MYSQL_PASSWORD and WORDPRESS_DB_PASSWORD are read from an [.env file](https://docs.docker.com/compose/env-file/))

As the port exposed by the official WordPress image is 80 I didn’t define VIRTUAL_PORT. Notice that it doesn’t have any ports section, because Nginx-proxy will take care of exposing them.

We’re ready! Now it’s time to start Compose for our Nginx-proxy instance, but don’t forget first to set the right Docker environment variables so that the commands are executed in our public Docker machine. I’ve tested this with a [Scaleway](https://www.scaleway.com/) baremetal server and they have a [Docker driver](https://github.com/scaleway/docker-machine-driver-scaleway) with quite good documentation.

Just issue an up command specifying the base file and the extension we’ve introduced:

`$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml up`


All of our containers running in the same Docker engine with a VIRTUAL_HOST variable should now be exposed through the reverse proxy we’ve just started!

One last important improvement: the default configuration that nginx-proxy provides has a relatively small client_max_body_size specially if you are running WordPress and want to upload files. To overcome that is why we have defined that second vhost.d volume where we can place a a file with the same name as the corresponding VIRTUAL_HOST variable. That file will be appended to the Nginx configuration for that site, therefore we can add the following file to allow large file uploads to our WP instance:


`client_max_body_size 1g;`

There are in-depth technical details in its [README](https://github.com/jwilder/nginx-proxy/blob/master/README.md) and also in [this post](http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/) referenced there.

Did it work for you? Feel free to leave your comments!
