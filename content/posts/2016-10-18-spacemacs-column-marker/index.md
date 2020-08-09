---
title: Column marker layer for Spacemacs
author: Mariano Benedettini
date: 2016-10-18
hero: 
excerpt: How to add a layer to Spacemacs to display a marker for column 80 
---

Well, I just switched from Prelude to Spacemacs and one of the first things I wanted is to know when I’m past the holy column #80 (actually when I'm about to get there, I never get past it lol).

I also wanted to get to know Spacemacs a bit so I decided to load [fci-mode](https://github.com/alpaker/Fill-Column-Indicator) from a layer. A layer is a configuration package in Spacemacs: it’s a collection of related packages along with some configuration you would like to add to them. You can read more about them at http://spacemacs.org/doc/DOCUMENTATION#configuration-layers

 
So his is what I ended up with: https://gist.github.com/mbenedettini/b5e15fa40029c17f071e95d298e3259a


```lisp
(defconst column-marker-packages
  '(fill-column-indicator)
  "The list of Lisp packages required by the column-marker layer.
Each entry is either:
1. A symbol, which is interpreted as a package to be installed, or
2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.
    The following keys are accepted:
    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil
    - :location: Specify a custom installation location.
      The following values are legal:
      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.
      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'
      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

(defun column-marker/init-fill-column-indicator ()
  (use-package fill-column-indicator
    :defer t
    :init
    (progn
      (setq fci-rule-column 80)
      (setq fci-rule-color "gray35")
      (eval-after-load 'js2-mode
        (add-hook 'js2-mode-hook 'fci-mode)
        )
      )
    ))

```

You will notice that it only gets loaded for `js2-mode` but loading it for another major mode is as easy as adding another eval-after-load section.

Improvements? Feel free to get in touch or leave a comment!

