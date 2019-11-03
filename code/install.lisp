(in-package #:sbcl-librarian)

(defparameter *installed* ";;; Leave this line for sbcl-librarian!")

(defun until (stream match)
  (let ((line (read-line stream nil nil)))
    (when line
      (when (not (search match line :test #'string=))
        (until stream match)))))

(defun installedp (sbclrc-path)
  "Determine if sbcl-librarian is installed in the .sbclrc."
  (with-open-file (sbclrc sbclrc-path
                          :direction :input
                          :if-does-not-exist nil)
    (when sbclrc (until sbclrc *installed*))))
(defun install (&optional (sbclrc-path *sbclrc-path*) (core-path *core-path*))
  (with-open-file (sbclrc sbclrc-path
                          :direction :output
                          :if-exists :append
                          :if-does-not-exist :create)
    (when (not (installedp sbclrc-path))
      (format sbclrc "~%~A~%" *installed*)
      (prin1 `(progn
                (when (probe-file ,core-path))
                (pushnew :sblibr *features*))
             sbclrc)
      (format sbclrc "~%~A~%" "#-sblibr")
      (prin1 '(asdf:load-system :sbcl-librarian) sbclrc)
      (format sbclrc "~%~A~%" "#-sblibr")
      (prin1 '(sbcl-librarian:update) sbclrc)
      (format sbclrc "~%")))
  (update core-path))
