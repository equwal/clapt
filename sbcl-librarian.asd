;;;; sbcl-librarian.asd

(asdf:defsystem #:sbcl-librarian
  :description "Load up projects and dump the core somewhere."
  :author "Spenser Truex <web@spensertruex.com>"
  :license  "GNU GPL v3"
  :version "0.0.1"
  :serial t
  :components ((:file "CONFIG-ASDF")
               (:file "CONFIG-QUICKLISP")
               (:file "code/package")
               (:file "code/early")
               (:file "code/save")
               (:file "code/install")))
