(in-package #:clapt)

(defvar *quicklisp-packages* nil)
(defvar *asdf-packages* nil)
(defvar *init-file* nil)

(defun install-ql (packages)
  (mapcar #'ql:quickload (mapcar #'symbol-name packages)))
(defun install-asdf (packages)
  (mapcar #'asdf:load-system packages))


(defun update (&optional (core *core-path*))
  (install-ql *quicklisp-packages*)
  (install-asdf *asdf-packages*)
  (save core))

(defun save (&optional (core *core-path*))
  ;; Should ensure that this is friendly. ~ is not allowed, does it actually
  ;; exist, etc.
  (sb-ext:save-lisp-and-die
   (asdf/pathname:ensure-absolute-pathname
    core)))

(defun add (manager &rest packages)
  (with-open-file (s *init-file*)
    (prin1
     `(progn
        ,@(loop for p in packages
                collect `(pushnew ,p
                                  (manager-packages-variable ,manager))))
     s)))

;;; Would be nice to have an interface here with continuations, friendly output
;;; and warnings, etc.
