---
title: Google contacts wiper
author: Mariano Benedettini
date: 2012-07-01
hero: 
excerpt: Python script that deletes all Google Contacts 
---

Thanks to some nasty Thunderbird add-on (I tried many of them, I’m not sure which is the guilty one), intended to keep the addressbook in sync with Google contacts, I ended up with more than 20.000 contacts in a group called “Other Contacts”, making my Android cellphone sluggish when syncing with my Google account.

I wrote a small Python script that deletes all of your Google Contacts. First, of course, make at least a backup of “My Contacts” so that you can restore them later. The script can be easily tweaked to only delete “Other contacts” but I didn’t care, I’d rather wipe them all.

Here is it: https://gist.github.com/3029734

It is based on a sample script from the python client samples: [contacts_example.py](https://github.com/google/gdata-python-client/blob/master/samples/contacts/contacts_example.py).

I also used information from https://developers.google.com/google-apps/contacts/v3/?hl=es-419.

You will need some extra Python modules. Both Google API and OAuth2 clients for Ubuntu can be downloaded from here.

If gflags module is missing in your system, it can be installed with PIP:

```
pip install gflags

```

(Install Pip itself with `aptitude install python-pip`)

If some other thing needs to be installed and I’m forgetting it, please let me know.

