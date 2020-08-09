---
title: Getting Nikola static site generator to work in OS X 10.9
author: Mariano Benedettini
date: 2013-12-30
hero: 
excerpt: Python life in OS X is not easy 
---


Yeah, Python life in OS X is not easy at all. As the folks at Devecoop decided to use Nikola, a great static site, for the official blog, then I proceeded to getting it to work in my laptop.

What happened is that it turns out that Python in OS X lacks the Berkeley DB module, which is a standard and default module!

Thanks to [this post](http://chriszf.posthaven.com/getting-berkeleydb-working-with-python-on-osx) I got bsddb3 installed and working.

Of course, Apple, that can’t be THAT easy! I managed to install ‘bsddb3’ but the dbhash module is trying to import just ‘bsddb’.

Then, I came across this other post which instructs you on how to modify dbhash to import ‘bsddb3’ instead of ‘bsddb’.

After that, I could successfully ‘pip install nikola’!

Here’s a little summary of what I had to do:

1) Install brew if you haven’t

2) Install berkeley-db
```
$ brew install berkeley-db
```
3) It’s not mandatory but I strongly advise to create a virtualenv. See https://bitbucket.org/dhellmann/virtualenvwrapper

4) Install bsddb3, but be explicit on the directory where berkeley-db can be found:
```
$ BERKELEYDB_DIR=/usr/local/Cellar/berkeley-db/5.3.28/ pip install bsddb3
```

5) In `/usr/local/Cellar/python/2.7.5/Frameworks/Python.framework/Versions/2.7/lib/python2.7/dbhash.py` replace every occurrence of bsddb with bsddb3

6) Finally!

`$ pip install nikola`


