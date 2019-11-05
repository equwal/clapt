(in-package #:clapt)

(define-condition packager (simple-condition) ())
(define-condition package-added (packager) ())
(define-condition package-ignored (packager) ())
(define-condition package-not-found (packager) ())
