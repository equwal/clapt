(in-package #:sbcl-librarian)

(defun save (&optional (core-path *core-path*))
  (load-configs)
  ;; Should ensure that this is friendly. ~ is not allowed, does it actually
  ;; exist, etc.
  (save-lisp-and-die
   (asdf/pathname:ensure-absolute-pathname
    (untilde core-path))))

(defun load-configs ()
  (with-open-file (q "CONFIG-QUICKLISP.lisp")
    (with-open-file (a "CONFIG-ASDF.lisp")
      (let ((qpack (verifying :quicklisp (read q)))
            (apack (verifying :asdf (read a))))
        (mapcar #'(lambda (fn lst)
                    (mapc fn lst)
                    (require lst))
                `(#',ql:quickload #',asdf:load-system)
                `(,apack ,qpack))))))

(defgeneric verifying (manager packages)
  (:documentation "Verify that packages exist for a given manager."))

;;; Would be nice to have an interface here with continuations, friendly output
;;; and warnings, etc.
(defmethod verifying ((manager :quicklisp) packages) packages)
(defmethod verifying ((manager :asdf) packages) packages)
