---
title: >-
  Speeding up Docker builds
author: Mariano Benedettini
date: 2018-10-03
hero: 
excerpt: >-
  Cache node_modules across CI builds
---

As you probably already know, Docker makes a pretty aggresive use of its cache and the criteria used to decide whether a layer can be reused is quite simple and well described in [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache).

Basically Docker just checks that the instruction in the Dockerfile has not changed and if that’s the case it will reuse the cached image. For ADD and COPY instructions it will check contents to see if something has changed.

In most Node projects we don’t install or remove a package often so it’s desirable to have our node_modules folders cached across builds. What we want is our Docker build to output something like this:

```console
Step 9/17 : RUN cd /usr/src/app && npm ci
---> Using cache
---> 37c1416a0392
```

Note that I’m using npm ci, which is the command that guarantees that you’re going to get exactly what your package-lock.json says: https://docs.npmjs.com/cli/ci

The technique is quite simple and consists in copying `package.json` and `package-lock.json` and issuing `npm ci` before adding/copying your code:

#### **`Dockerfile`**
```dockerfile
COPY package.json /usr/src/app
COPY package-lock.json /usr/src/app
RUN cd /usr/src/app && npm ci
```

That way, if both your `package.json` and `package-lock.json` didn’t change, the cache will be valid when Docker reaches `npm ci` and your build will be blazingly fast.

To give more context here’s a sample Dockerfile with it:

#### **`Dockerfile`**
```Dockerfile
COPY package.json /usr/src/app
FROM marianobe/node-base:latest
EXPOSE 3000 3001 3002

RUN npm install -g --unsafe-perm @angular/cli pushstate-server

RUN mkdir -p /usr/src/app/client
WORKDIR /usr/src/app

# Loopback app
COPY package.json /usr/src/app
COPY package-lock.json /usr/src/app
RUN cd /usr/src/app && npm ci

# Angular app
COPY ./client/package.json /usr/src/app/client
COPY ./client/package-lock.json /usr/src/app/client
RUN cd /usr/src/app/client && npm ci

COPY . /usr/src/app

WORKDIR /usr/src/app/client
RUN npm run build
```
