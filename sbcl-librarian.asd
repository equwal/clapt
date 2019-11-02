;;;; sbcl-librarian.asd

(asdf:defsystem #:sbcl-librarian
  :description "Describe sbcl-librarian here"
  :author "Spenser Truex <web@spensertruex.com>"
  :license  "GNU GPL v3"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "sbcl-librarian")))
