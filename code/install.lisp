(in-package #:clapt)

(defparameter *installed* ";;; Leave this line for sbcl-librarian!")
(defparameter *logstream* t)
(defparameter *userstream* t)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun packages-doc (manager)
    (format
     nil
     "~A~A~A"
     "User configured Packages for "
     (string-downcase (symbol-name manager))
     ". `clapt:add' is a convenience wrapper for it.")))
#+5am (packages-doc :quicklisp)


(defun install (&key (sbclrc *sbclrc-path*) (core *core-path*)
                  (add '(:quicklisp :asdf)))
  "Install clapt."
  (when (not (installedp sbclrc))
    (write-to-init-file sbclrc core add))
  (backup-core core (merge-pathnames #P".core.bak" sbclrc))
  (update core))


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

#+5am (backup-core #p"~/org/sbcl.org" #p"~/example.delete")
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

(defun write-to-init-file (sbclrc core systema)
  "Common Lisp code in the init file for cl-apt to install itself if not
installed. Provides persistence even when a new version is built."
  (with-open-file (s sbclrc
                     :direction :output
                     :if-exists :append
                     :if-does-not-exist :create)
    (when (not (installedp sbclrc))
      (parameterize s systema)
      (self-install s core))))

(defun package-parameter (packages manager)
  `(defvar ,(intern (symbol-name manager)
                          (find-package :keyword))
     ',packages
     ,(packages-doc manager)))
#+5am (package-parameter '(petalisp) :quicklisp)

(defun self-install (sbclrc core)
  (declare (stream sbclrc))
  (declare (pathname core))
  (format sbclrc "~%~A~%" *installed*)
  (prin1 `(progn
            (when (probe-file ,core))
            (pushnew :clapt *features*))
         sbclrc)
  (format sbclrc "~%~A~%" "#-clapt")
  (prin1 '(asdf:load-system :clapt) sbclrc)
  (format sbclrc "~%~A~%" "#-clapt")
  (prin1 '(clapt:update) sbclrc)
  (format sbclrc "~%"))

(defun parameterize (sbclrc systema)
  (declare (stream sbclrc))
  (mapcar #'(lambda (code) (prin1 code sbclrc))
          (loop for s in systema
                collect (package-parameter systema s))))
