(in-package #:clapt)

(defun until (stream match)
  (let ((line (read-line stream nil nil)))
    (when line
      (when (not (search match line :test #'string=))
        (until stream match)))))
