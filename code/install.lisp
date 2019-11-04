(in-package #:clapt)

(defparameter *installed* ";;; Leave this line for sbcl-librarian!")

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

(defun installedp (sbclrc-path)
  "Determine if sbcl-librarian is installed in the .sbclrc."
  (with-open-file (sbclrc sbclrc-path
                          :direction :input
                          :if-does-not-exist nil)
    (when sbclrc (until sbclrc *installed*))))

(defun backup-core (core backup)
  "Save original core image."
  (copy-file core backup (* 1024 1024)))

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
