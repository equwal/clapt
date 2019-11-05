(in-package #:clapt)

(defparameter *installed* ";;; Leave this line for clapt!")
(defparameter *logstream* t)
(defparameter *userstream* t)

(defun install (&key (sbclrc *sbclrc-path*) (core *core-path*)
                  (add '(:quicklisp :asdf)))
  "Install clapt."
  (when (not (installedp sbclrc))
    (write-to-init-file sbclrc add))
  (backup-core core (merge-pathnames #P".core.bak" sbclrc)))

(defun installedp (sbclrc-path)
  "Determine if sbcl-librarian is installed in the .sbclrc."
  (with-open-file (sbclrc sbclrc-path
                          :direction :input
                          :if-does-not-exist nil)
    (when sbclrc (until sbclrc *installed*))))

(defmacro warner (level datum &rest arguments)
  "Use log  to manage output."
  ;; This is ugly like this because using variables for a format spec is
  ;; considered bad style.
  (case level
    (error `(error ,datum ,@arguments))
    (warn `(warn ,datum ,@arguments))
    (log `(format *logstream* (concatenate 'string "LOG: "
                                           ,datum)
                  ,@arguments))
    (user `(format *userstream* ,datum ,@arguments))
    (otherwise (error "Bad warning spec."))))

;; (backup-core #p"~/org/sbcl.org" #p"~/example.delete")
(defun backup-core (core backup)
  "Save original core image."
  (handler-case (copy-file core backup)
    (:no-error (nothing)
      (declare (ignore nothing))
      (warner user "~@{~a~}"
              "Core was backed up from:"
              (format nil "~%")
              core
              (format nil "~%to:~%")
              backup
              (format nil "~%")))
    (file-error (path-obj)
      (let ((fail (file-error-pathname path-obj)))
        (cond ((uiop:pathname-equal fail core)
               (warner warn "~@{~a~}"
                       "The core does not exist, sbcl will have"
                       " to be started "
                       (format nil "with the:~%--core \"")
                       fail
                       (format nil "\"~%option to enable the ")
                       (format nil "libraries core.~%")))
              ((uiop:pathname-equal fail backup)
               (warner log "~@{~a~}"
                       "The backup was aborted because there already is"
                       (format nil " one there at:~%")
                       fail
                       (format nil "~%and it is ")
                       (format nil "probably the vanilla one.~%")))
              (t (warner error "~@{~a~}"
                         "Unexpected backup failure. Submit a bug report:"
                         (format nil "~%core: ") core
                         (format nil "~%backup: ") backup
                         (format nil "~%failure path: ") fail
                         (format nil "~%"))))))))

(defun write-to-init-file (sbclrc systema)
  "Common Lisp code in the init file for cl-apt to install itself if not
installed. Provides persistence even when a new version is built."
  (with-open-file (s sbclrc
                     :direction :output
                     :if-exists :append
                     :if-does-not-exist :create)
    (when (not (installedp sbclrc))
      (self-install s)
      (parameterize s systema)
      (init s sbclrc))))

(defun init (stream init)
  (print
   `(setf *init-file* ,init)
   stream))


(defun manager-packages-variable (manager)
  (intern (concatenate 'string "*" (symbol-name manager) "-PACKAGES*")
          (find-package :clapt)))
(defun manager-packages (manager)
  (symbol-value (manager-packages-variable manager)))
(defun pushnew-package (manager package)
  ;; Needs EVAL because the interface -- anaphoric interning -- is not very
  ;; good.
  (eval (let ((packages (manager-packages manager)))
          `(setf ,(manager-packages-variable manager)
                 ',(pushnew package packages)))))
;; (let ((q :quicklisp)) (pushnew-package q 'bogus))
;; (manager-packages :quicklisp)

(defun package-parameter (packages manager)
  `(setf ,(manager-packages-variable manager)
     ',packages))
;; (package-parameter '(petalisp) :quicklisp)

(defun self-install (sbclrc)
  (declare (stream sbclrc))
  (format sbclrc "~%~A~%" "#-clapt")
  (prin1 '(asdf:load-system :clapt) sbclrc)
  (format sbclrc "~%~A~%" "#-clapt")
  (prin1 '(clapt:update) sbclrc)
  (format sbclrc "~%")
  (format sbclrc "~%~A~%" *installed*))

(defun parameterize (sbclrc systema)
  (declare (stream sbclrc))
  (mapcar #'(lambda (code) (print code sbclrc))
          (loop for s in systema
                collect (package-parameter nil s))))
