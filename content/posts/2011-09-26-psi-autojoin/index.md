---
title: "PSI: Auto join groupchat at a certain time"
author: Mariano Benedettini
date: 2011-09-26
hero: 
excerpt: "PSI: Auto join groupchat at a certain time" 
---


In my job we have a daily chat that everyone must join at 10 AM. I'm using PSI as the
xmpp client and that's easy to do from Psi command line interface with a cronjob:


```
59 9 * * 1,2,3,4,5 DISPLAY=:0.0 /usr/bin/psi --remote --uri=xmpp:daily@conference.mychatserver.com?join

```
