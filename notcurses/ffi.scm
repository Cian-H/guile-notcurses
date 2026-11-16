;;; notcurses/ffi.scm — Library discovery and FFI plumbing for guile-notcurses.
;;;
;;; Adapted from badb's (geasa surfaces-tui nc) library discovery and FFI
;;; helpers. Loads libnotcurses, libnotcurses-core, and libnotcurses-ffi
;;; across GUIX_ENVIRONMENT, ~/.guix-profile, and the system loader.

(define-module (notcurses ffi)
  #:use-module (srfi srfi-1)
  #:use-module (system foreign)
  #:use-module (system foreign-library)
  #:export (%notcurses-handles
            %libc-handle
            library-candidates
            resolve-type
            lookup-procedure
            define-nc
            ->c-string
            c-string->scheme
            c-string-free->scheme
            %c-free
            %c-fopen
            %c-fdopen
            %c-fclose
            %c-nanosleep
            %c-ioctl))

(define (library-candidates soname)
  "Return candidate paths for SONAME, checking GUIX_ENVIRONMENT,
~/.guix-profile, and finally the bare soname for the system loader."
  (append
   (filter-map
    (lambda (dir) (and dir (string-append dir "/lib/" soname)))
    (list (getenv "GUIX_ENVIRONMENT")
          (and=> (getenv "HOME")
                 (lambda (h) (string-append h "/.guix-profile")))))
   (list soname)))

(define (load-first-available soname)
  (let loop ((paths (library-candidates soname)))
    (if (null? paths)
        #f
        (or (false-if-exception (load-foreign-library (car paths)))
            (loop (cdr paths))))))

(define %notcurses-handles
  (filter-map load-first-available
              '("libnotcurses.so.3"
                "libnotcurses-core.so.3"
                "libnotcurses-ffi.so.3")))

(when (null? %notcurses-handles)
  (error "libnotcurses not found; ensure notcurses 3.x is installed or GUIX_ENVIRONMENT is active"))

(define %libc-handle
  (load-first-available "libc.so.6"))

(define %ffi-type-map
  `((int . ,int)
    (unsigned-int . ,unsigned-int)
    (unsigned . ,unsigned-int)
    (int8 . ,int8)
    (char . ,int8)
    (uint8 . ,uint8)
    (bool . ,uint8)
    (int16 . ,int16)
    (short . ,int16)
    (uint16 . ,uint16)
    (unsigned-short . ,uint16)
    (int32 . ,int32)
    (wchar . ,int32)
    (uint32 . ,uint32)
    (wint . ,uint32)
    (int64 . ,int64)
    (uint64 . ,uint64)
    (size_t . ,size_t)
    (ssize_t . ,ssize_t)
    (long . ,long)
    (unsigned-long . ,unsigned-long)
    (float . ,float)
    (double . ,double)
    (void . ,void)
    (* . *)))

(define (resolve-type t)
  "Translate declarative FFI type symbols to (system foreign) type objects."
  (or (assq-ref %ffi-type-map t) t))

(define (lookup-procedure name ret arg-types)
  "Resolve C symbol NAME across %notcurses-handles and return a foreign procedure."
  (let ((c-ret (resolve-type ret))
        (c-args (map resolve-type arg-types)))
    (let loop ((handles %notcurses-handles))
      (if (null? handles)
          (error "notcurses symbol not found" name)
          (or (false-if-exception
               (pointer->procedure c-ret
                                   (dynamic-func name (car handles))
                                   c-args))
              (loop (cdr handles)))))))

(define-syntax define-nc
  (lambda (stx)
    (syntax-case stx ()
      ((_ scheme-name c-name ret (arg-type ...))
       (with-syntax (((arg ...) (generate-temporaries #'(arg-type ...))))
         #'(define scheme-name
             (let ((proc (lookup-procedure c-name 'ret '(arg-type ...)))
                   (ret-bool? (eq? 'ret 'bool))
                   (arg-bools (map (lambda (t) (eq? t 'bool)) '(arg-type ...))))
               (cond
                 ((memq #t arg-bools)
                  (lambda (arg ...)
                    (let ((res (apply proc (map (lambda (a b?) (if b? (if a 1 0) a))
                                                (list arg ...) arg-bools))))
                      (if ret-bool? (not (zero? res)) res))))
                 (ret-bool?
                  (lambda (arg ...)
                    (not (zero? (proc arg ...)))))
                 (else proc)))))))))

(define (->c-string s)
  "Convert Scheme string S to a C pointer, or %null-pointer if S is #f."
  (cond
    ((not s) %null-pointer)
    ((pointer? s) s)
    (else (string->pointer s))))

(define (c-string->scheme ptr)
  "Convert C string pointer PTR to a Scheme string, or #f if NULL."
  (if (or (not ptr) (null-pointer? ptr))
      #f
      (pointer->string ptr)))

(define %c-free
  (and %libc-handle
       (false-if-exception
        (pointer->procedure void (dynamic-func "free" %libc-handle) '(*)))))

(define %c-fopen
  (and %libc-handle
       (false-if-exception
        (pointer->procedure '* (dynamic-func "fopen" %libc-handle) '(* *)))))

(define %c-fdopen
  (and %libc-handle
       (false-if-exception
        (pointer->procedure '* (dynamic-func "fdopen" %libc-handle) (list int '*)))))

(define %c-fclose
  (and %libc-handle
       (false-if-exception
        (pointer->procedure int (dynamic-func "fclose" %libc-handle) '(*)))))

(define %c-nanosleep
  (and %libc-handle
       (false-if-exception
        (pointer->procedure int (dynamic-func "nanosleep" %libc-handle) '(* *)))))

(define %c-ioctl
  (and %libc-handle
       (false-if-exception
        (pointer->procedure int (dynamic-func "ioctl" %libc-handle) (list int unsigned-long '*)))))

(define (c-string-free->scheme ptr)
  "Convert malloc'd C string PTR to a Scheme string and free(PTR), or #f if NULL."
  (if (or (not ptr) (null-pointer? ptr))
      #f
      (let ((s (pointer->string ptr)))
        (when %c-free
          (%c-free ptr))
        s)))
