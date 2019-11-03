;;;;;
title: Librarian
format: md
date: 2019-11-02
tags: articles
excerpt: Faster SBCL startup with libraries.
image: /static/librarian.png
;;;;;

[Official webpage](https://spensertruex.com/librarian)

![Librarian icon](https://spensertruex.com/static/librarian-mini.png)

# sbcl-librarian

Instant SBCL startup with any number of ASDF libraries by loading the and
dumping a core once.

## Install

We need to know which packages are needed, and whether they are from quicklisp. Modify `CONFIG-ASDF.lisp` and/or `CONFIG-QUICKLISP.lisp`.

## License

GNU GPL v3

### _Spenser Truex <web@spensertruex.com>_
