---
title: Unofficial libmsn4.2 package for Ubuntu 11.10 Oneiric Ocelot
author: Mariano Benedettini
pubDatetime: 2011-11-15
hero: 
excerpt: Unofficial libmsn4.2 package for Ubuntu 11.10 Oneiric Ocelot
description: ""
---

[ aka: kopete msn won’t connect ]

As you may already figured out, Microsoft recently made some changes to their Live/MSN service (around November 8th) and since then, Kopete msn support is broken.

The problem lies on the library libmsn, which was updated but Ubuntu hasn’t released a new package, yet. What I have done is a new 32-bit Ubuntu package against the latest libmsn, which is 4.2.

You can download it [here](http://ubuntuone.com/0xp9LicHPCE921QjhUQWE8) and install it with dpkg:

```
mariano@laptop:~/Downloads$ sudo dpkg -i libmsn0.3_4.2-1_i386.deb
(Reading database ... 257674 files and directories currently installed.)
Preparing to replace libmsn0.3 4.1-2ubuntu1 (using libmsn0.3_4.2-1_i386.deb) ...
Unpacking replacement libmsn0.3 ...
Setting up libmsn0.3 (4.2-1) ...
Processing triggers for libc-bin ...
ldconfig deferred processing now taking place.
```

Remember to close and open kopete again if it was running at the moment of the update.




