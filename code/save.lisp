(in-package #:sbcl-librarian)

(defun update (&optional (core *core-path*))
  (load-configs)
  (save core))

(defun save (&optional (core *core-path*))
  ;; Should ensure that this is friendly. ~ is not allowed, does it actually
  ;; exist, etc.
  (sb-ext:save-lisp-and-die
   (asdf/pathname:ensure-absolute-pathname
    core)))

(defun load-configs ()
  (mapcar #'(lambda (fn pkg)
              (when pkg
                (mapc fn pkg)
                (require pkg)))
          (list #'ql:quickload #'asdf:load-system)
          (list (verify-ql *quicklisp-packages*)
                (verify-asdf *asdf-packages*))))

(defun verify-ql (packages) (macpar #'symbol-name packages))
(defun verify-asdf (packages) (mapcar #'symbol-name packages))

;;; Would be nice to have an interface here with continuations, friendly output
;;; and warnings, etc.
