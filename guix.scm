;;; guix.scm — Guix package definition for guile-notcurses.
;;;
;;; Build locally with:
;;;   guix build -f guix.scm
;;; Enter a shell with guile-notcurses pre-compiled and on load path:
;;;   guix shell -f guix.scm

(use-modules (guix packages)
             (guix gexp)
             (guix build-system guile)
             ((guix licenses) #:prefix license:)
             (gnu packages guile)
             (gnu packages notcurses))

(package
  (name "guile-notcurses")
  (version "3.0.16")
  (source (local-file "."
                      "guile-notcurses-checkout"
                      #:recursive? #t
                      #:select? (lambda (file stat)
                                  (not (or (string-contains file "/ccache")
                                           (string-contains file "/.git")
                                           (string-suffix? ".log" file))))))
  (build-system guile-build-system)
  (native-inputs
   (list guile-3.0))
  (inputs
   (list notcurses))
  (arguments
   (list
    #:source-directory "."
    #:not-compiled-file-regexp "(^|/)(guix\\.scm|tests/.*)$"
    #:compile-flags #~'("-O2")
    #:phases
    #~(modify-phases %standard-phases
        (add-after 'unpack 'patch-library-paths
          (lambda* (#:key inputs #:allow-other-keys)
            (let ((nc-lib (string-append (assoc-ref inputs "notcurses") "/lib")))
              (substitute* "notcurses/ffi.scm"
                (("\"libnotcurses\\.so\\.3\"")
                 (string-append "\"" nc-lib "/libnotcurses.so.3\""))
                (("\"libnotcurses-core\\.so\\.3\"")
                 (string-append "\"" nc-lib "/libnotcurses-core.so.3\""))
                (("\"libnotcurses-ffi\\.so\\.3\"")
                 (string-append "\"" nc-lib "/libnotcurses-ffi.so.3\""))))))
        (add-after 'build 'check
          (lambda* (#:key tests? #:allow-other-keys)
            (when tests?
              (setenv "GUILE_LOAD_PATH" (getcwd))
              (setenv "GUILE_LOAD_COMPILED_PATH"
                      (string-append (getcwd) ":" (or (getenv "GUILE_LOAD_COMPILED_PATH") "")))
              (for-each
               (lambda (t)
                 (invoke "guile" "--no-auto-compile" t))
               '("tests/test-ffi-coverage.scm"
                 "tests/test-structs.scm"
                 "tests/test-channels-cells.scm"
                 "tests/test-compat-curses.scm"))))))))
  (home-page "https://github.com/Cian-H/guile-notcurses")
  (synopsis "Complete thin GNU Guile 3.x FFI wrapper for libnotcurses 3.x")
  (description
   "guile-notcurses provides complete thin GNU Guile 3.x FFI bindings to
libnotcurses 3.x (core, planes, cells, channels, input, visuals, direct mode,
and widgets), bytevector-backed C struct wrappers, terminal utilities, and an
optional curses compatibility layer.")
  (license license:lgpl3+))
