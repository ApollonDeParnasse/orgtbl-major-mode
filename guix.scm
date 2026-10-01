;;; guix.scm --- Guix package for orgtbl-major-mode

(define-module (orgtbl-major-mode)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix licenses)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system emacs)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-build)
  #:use-module (packages generate))

(define-public orgtbl-major-mode
  (package
    (name "orgtbl-major-mode")
    (version "0.0.0")
    (source (local-file (getcwd) #:recursive? #t))
    (build-system emacs-build-system)
    (inputs (list emacs-dash emacs-s emacs-compat generate))
    (native-inputs (list git))
    (synopsis "A major mode for org-table")
    (description "A major mode for org-table")
    (home-page "https://github.com/ApollonDeParnasse/orgtbl-major-mode")
    (license gpl3)))

orgtbl-major-mode
;;; guix.scm ends here
