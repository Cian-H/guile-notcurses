;;; tests/test-ffi-coverage.scm — Verify FFI bindings and core metadata.

(use-modules (ice-9 rdelim)
             (srfi srfi-64)
             (rnrs bytevectors)
             (system foreign)
             (notcurses))

(define expected-notcurses-version
  (let ((vf (string-append (dirname (current-filename)) "/../.notcurses-version")))
    (string-trim-both (call-with-input-file vf read-line))))

(test-begin "ffi-coverage")

(test-equal "notcurses_version matches locked version"
  expected-notcurses-version
  (c-string->scheme (notcurses_version)))

(test-assert "notcurses_version_components reports a 3.x version"
  (let ((maj (make-bytevector 4 0))
        (min (make-bytevector 4 0))
        (pat (make-bytevector 4 0))
        (twk (make-bytevector 4 0)))

    (notcurses_version_components
      (bytevector->pointer maj)
      (bytevector->pointer min)
      (bytevector->pointer pat)
      (bytevector->pointer twk))

    (and (= 3 (bytevector-s32-native-ref maj 0))
         (>= (bytevector-s32-native-ref min 0) 0)
         (>= (bytevector-s32-native-ref pat 0) 0))))

(test-equal "notcurses_str_blitter"
  "braille"
  (c-string->scheme (notcurses_str_blitter NCBLIT_BRAILLE)))

(test-equal "notcurses_str_scalemode"
  "scale"
  (c-string->scheme (notcurses_str_scalemode NCSCALE_SCALE)))

(test-assert "key constants match nckeys.h"
  (and (= NCKEY_INVALID 1115000)
       (= NCKEY_RESIZE 1115001)
       (= NCKEY_UP 1115002)
       (= NCKEY_ENTER 1115121)
       (= NCOPTION_SUPPRESS_BANNERS #x20)
       (= NCSTYLE_BOLD #x02)))

(test-assert "all submodule exports are bound procedures"
  (let ((submodules '((notcurses core)
                      (notcurses channel)
                      (notcurses cell)
                      (notcurses plane)
                      (notcurses input)
                      (notcurses visual)
                      (notcurses direct)
                      (notcurses widgets))))
    (let loop ((mods submodules))
      (if (null? mods)
          #t
          (let* ((iface (resolve-interface (car mods)))
                 (ok #t))
            (module-for-each
             (lambda (sym var)
               (unless (procedure? (variable-ref var))
                 (set! ok #f)))
             iface)
            (and ok (loop (cdr mods))))))))

(test-end "ffi-coverage")
