(in-package #:sbcl-librarian)

(defun untilde (path)
  "Ensure the has no tilde."
  (if (char= #\~ (elt path 0))
      (merge-pathnames (user-homedir-pathname)
                       (subseq path 2))
      path))

(defparameter *core-path* (untilde "~/.sbcl-library.core")
  "The default place to store the library core.")
(defparameter *sbclrc-path* (untilde "~/.sbclrc"))
