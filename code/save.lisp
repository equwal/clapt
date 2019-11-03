(in-package #:sbcl-librarian)

(defun update (&optional (core-path *core-path*))
  (load-configs)
  (save core-path))

(defun save (&optional (core-path *core-path*))
  ;; Should ensure that this is friendly. ~ is not allowed, does it actually
  ;; exist, etc.
  (sb-ext:save-lisp-and-die
   (asdf/pathname:ensure-absolute-pathname
    core-path)))

(defun load-configs ()
  (mapcar #'(lambda (fn pkg)
              (when pkg
                (mapc fn pkg)
                (require pkg)))
          (list #'ql:quickload #'asdf:load-system)
          (list (verify-ql *quicklisp-packages*)
		(verify-asdf *asdf-packages*))))

(defun verify-ql (packages) packages)
(defun verify-asdf (packages) packages)

;;; Would be nice to have an interface here with continuations, friendly output
;;; and warnings, etc.
