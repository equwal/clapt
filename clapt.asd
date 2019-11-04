(asdf:defsystem #:clapt
  :description "Load up projects and dump the core somewhere."
  :author "Spenser Truex <web@spensertruex.com>"
  :license  "GNU GPL v3"
  :version "0.0.2"
  :serial t
  :components ((:file "package")
               (:file "code/util")
               (:file "code/defaults")
               (:file "code/save")
               (:file "code/install")))
