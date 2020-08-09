---
title: Connect-redis and redis-server version in Debian Squeeze
author: Mariano Benedettini
date: 2013-10-13
hero: 
excerpt: NodeJS stuff 
---

Today I ran into a strange behaviour of connect-redis, the Redis session store for Connect.

In development environment it worked like a charm: I switched from MemoryStore to RedisStore in my Node.JS application without a single problem. My development environment OS is Ubuntu 12.10.

However, when I tried it in production, strange things started to happen. For some reason Connect was not being able to store sessions into Redis. After comparing packages (both debian and node.js) between both environments I found out that redis-server version was rather old. Production OS is Debian Squeeze and its redis-server version is 1.2.6 (http://packages.debian.org/squeeze/redis-server) while in Ubuntu 12.10 is 2.4.15.

Without looking into the differences between Redis versions that might be causing the problem I decided to upgrade redis-server in production. Luckily there are backports of it!: https://chris-lamb.co.uk/posts/official-redis-packages-debian-squeeze. As you might imagine, after upgrading redis-server to the current backport version (`2:2.4.15-1~bpo60+2`) everything worked just fine.

