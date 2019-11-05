(in-package #:clapt)

;; TODO: Use actual conditions properly for the user.
;; Use this when checking if the package exists.
;; (warner error "~@{~a~}~%" "Could not add the " package " package.")

(defun add (manager &rest packages)
  (add-signal manager packages)
  (warner user "~a~%" "run (clapt:update) to install them and die."))

(defun add-signal (manager packages)
  "Assumes already installed."
  (with-open-file (f *init-file*
                     :direction :output
                     :if-exists :append)
    (loop for p in packages
          do (add-once manager p f))))

(defun add-once (manager package stream)
  (let ((pn (equalp (manager-packages manager)
                    (pushnew-package manager package))))
    (when (not pn)
      (print
       `(pushnew ',package ,(manager-packages-variable manager))
       stream))
    (if pn
        (warner user "~@{~a~}~%" "Ignored the " package " package, "
                "since it is already installed.")
        (warner user "~@{~a~}~%" "Added the " package " package."))
    package))
