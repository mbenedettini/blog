---
title: OS X notifications for Emacs-jabber
author: Mariano Benedettini
pubDatetime: 2015-04-05
hero: 
excerpt: How to send notifications to OSX from emacs-jabber 
description: ""
---


Where I work we have a jabber-based chat service to communicate with each other and of course I use the excellent [emacs-jabber](http://emacs-jabber.sourceforge.net/) to chat from within Emacs.

The (huge) problem was that my colleagues were complaining that I weren’t noticing some of their messages! And that happened when I switched, for instance, from Emacs to Firefox. That was because Emacs wasn’t notifying me of the new messages. I could have switched to Adium, but I like to keep everything related with work in a single environment.

Here are some quick step-by-step instructions to get OS X notifications for every new message received in Emacs-jabber.

1) We’re going to use [terminal-notifier](https://github.com/alloy/terminal-notifier) to send notifications from Emacs to OS X. Although it comes with prebuilt binaries I highly recommend Homebrew to install it and many other common packages (ack, wget, mysql, python, etc). Give it a try, you will love it. Once installed, you can test it with a simple example such as:

`/usr/local/bin/terminal-notifier -sender org.gnu.Emacs -title 'Message title' -message 'This is the message content!'`


Please refer to terminal-notifier itself for more details on its usage.

2) Now the only pending task is to tell Emacs to send notifications via a shell command executing terminal-notifier. Add the following lines to your .emacs :

```
(defun msg-via-notifier (title msg)
(shell-command (format "/usr/local/bin/terminal-notifier -sender org.gnu.Emacs -title '%s' -message '%s'" title msg) )
)
(defun notify-jabber-message (from buf text proposed-alert)
(msg-via-notifier from text))
(add-hook 'jabber-alert-message-hooks 'notify-jabber-message)
```

3) That’s it!

You can also test the recently added msg-via-notifier function (after restarting Emacs) generating an example notification from Emacs:

`(msg-via-notifier "Notification title" "Notification content")`

