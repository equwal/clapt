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

We need to know which packages are needed, and whether they are from quicklisp.

1. Modify `CONFIG-ASDF.lisp` and/or `CONFIG-QUICKLISP.lisp` with the desired
   packages. Alternatively, set the `sbcl-librarian:*asdf-packages*` and/or
   `sbcl-librarian:*quicklisp-packges*` in your `.sbclrc` file.
2. Load the package: `(asdf:load-system :sbcl-librarian)`
3. Install: `(sbcl-librarian:install)`. SBCL will save and die.

By default sbcl-librarian will try to overwrite your installed core file. This
may require root access on your system; alternatively, try
`(sbcl-librarian:install :core "path-to-your-core")` for a different core.

## Updating packages

 `(sbcl-librarian:update)`. SBCL will save and die again.

## License

GNU GPL v3

### _Spenser Truex <web@spensertruex.com>_
