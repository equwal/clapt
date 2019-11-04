(in-package #:clapt)

(defun write-array (array stream)
  "Write a binary array to the unsigned-byte stream."
  (loop for x across array
        do (write-byte x stream)))

(defun copy-stream (from to size buffer loc)
  "Copy an unsigned-byte stream to another one, somewhat efficiently."
  (if (< loc size)
      (let ((byte (read-byte from nil nil)))
        (if byte
            (copy-stream from to size
                         (progn (setf (aref buffer loc) byte) buffer)
                         (1+ loc))
            (write-array (subseq buffer 0 loc) to)))
      (progn (write-array buffer to)
             (copy-stream from to size buffer 0))))

(defun copy-file (from to &optional (buffer-size 1024))
  (with-open-file (fr from
                      :element-type 'unsigned-byte
                      :if-does-not-exist nil)
    (if fr
        (with-open-file (to to :direction :output
                               :if-exists nil ;Want it to stay ORIGINAL.
                               :if-does-not-exist :create
                               :element-type 'unsigned-byte)
          (when to
            (copy-stream fr to buffer-size
                         (make-array buffer-size :element-type 'unsigned-byte)
                         0)))
        (warn "~%~%The core does not exist, sbcl will have to be started with the --core ~S option to enable the sbcl-librarian libraries core.~%~%" from))))

(defun until (stream match)
  (let ((line (read-line stream nil nil)))
    (when line
      (when (not (search match line :test #'string=))
        (until stream match)))))
