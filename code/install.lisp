(in-package #:sbcl-librarian)

(defparameter *installed* ";;; Leave this line for sbcl-librarian!")

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

(defun installedp (sbclrc-path)
  "Determine if sbcl-librarian is installed in the .sbclrc."
  (with-open-file (sbclrc sbclrc-path
                          :direction :input
                          :if-does-not-exist nil)
    (when sbclrc (until sbclrc *installed*))))

(defun write-to-init-file (sbclrc-path core-path)
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
      (format sbclrc "~%"))))

(defun backup-core (core backup)
  (copy-file core backup (* 1024 1024)))

(defun install (&key (sbclrc *sbclrc-path*) (core *core-path*))
  (when (not (installedp sbclrc))
    (write-to-init-file sbclrc core))
  (backup-core core (merge-pathnames #P".core.bak" sbclrc))
  (update core))
