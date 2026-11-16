;;; notcurses/terminal.scm — Terminal utilities for notcurses applications.
;;;
;;; Adapted from badb's (geasa surfaces-tui nc): stderr redirection during
;;; alternate-screen sessions, DECSCUSR cursor shape control, BEL beep,
;;; TIOCGWINSZ terminal-resize polling, and nanosleep-based millisecond sleep.

(define-module (notcurses terminal)
  #:use-module (rnrs bytevectors)
  #:use-module (system foreign)
  #:use-module (notcurses ffi)
  #:export (redirect-stderr-for-tui!
            restore-stderr-for-tui!
            tty-control-port
            cursor-shape
            beep
            sync-known-size!
            terminal-size-changed?
            known-terminal-rows
            known-terminal-cols
            sleep-ms))

(define %saved-stderr-fd #f)
(define %tty-control-port #f)

(define (tty-control-port)
  "Return the saved tty output port when stderr is redirected, or #f."
  %tty-control-port)

(define* (redirect-stderr-for-tui! #:optional (log-path "/dev/null"))
  "Redirect OS file descriptor 2 (stderr) away from the terminal while
notcurses owns the alternate screen, so C-level GC warnings or stray
stderr writes cannot scroll or corrupt the display."
  (unless %saved-stderr-fd
    (catch #t
      (lambda ()
        (let* ((saved (dup->fdes 2))
               (log-fd (catch #t
                         (lambda ()
                           (open-fdes log-path (logior O_WRONLY O_CREAT O_APPEND) #o644))
                         (lambda _
                           (open-fdes "/dev/null" O_WRONLY)))))
          (dup2 log-fd 2)
          (close-fdes log-fd)
          (set! %saved-stderr-fd saved)
          (set! %tty-control-port (fdes->outport saved))))
      (lambda _ #f))))

(define (restore-stderr-for-tui!)
  "Restore OS file descriptor 2 (stderr) when leaving the TUI."
  (when %saved-stderr-fd
    (catch #t
      (lambda ()
        (when %tty-control-port
          (force-output %tty-control-port))
        (dup2 %saved-stderr-fd 2)
        (when %tty-control-port
          (close-port %tty-control-port))
        (set! %tty-control-port #f)
        (set! %saved-stderr-fd #f))
      (lambda _
        (set! %tty-control-port #f)
        (set! %saved-stderr-fd #f)))))

(define %cursor-shape-codes
  '((default . 0)
    (block-blink . 1)
    (block . 2)
    (underline-blink . 3)
    (underline . 4)
    (bar-blink . 5)
    (bar . 6)))

(define %last-cursor-shape 'none)

(define (cursor-shape shape)
  "Set the terminal cursor SHAPE (a symbol from default, block-blink, block,
underline-blink, underline, bar-blink, bar) via DECSCUSR."
  (let ((code (assq-ref %cursor-shape-codes shape)))
    (when (and code (not (eq? shape %last-cursor-shape)))
      (catch #t
        (lambda ()
          (let ((p (or %tty-control-port (current-error-port))))
            (format p "\x1b[~a q" code)
            (force-output p)))
        (lambda _ #f))
      (set! %last-cursor-shape shape))))

(define (beep)
  "Ring the terminal bell without disturbing the rendered frame."
  (catch #t
    (lambda ()
      (let ((p (or %tty-control-port (current-error-port))))
        (display "\a" p)
        (force-output p)))
    (lambda _ #f)))

;; TIOCGWINSZ on x86_64 Linux: 0x5413
(define %tiocgwinsz #x5413)
(define %winsize (make-bytevector 8 0))
(define %known-rows 0)
(define %known-cols 0)

(define (known-terminal-rows) %known-rows)
(define (known-terminal-cols) %known-cols)

(define* (sync-known-size! #:optional (fd 1))
  "Query ioctl(TIOCGWINSZ) on FD and cache the terminal's rows and columns."
  (when (and %c-ioctl
             (zero? (%c-ioctl fd %tiocgwinsz (bytevector->pointer %winsize))))
    (set! %known-rows (bytevector-u16-native-ref %winsize 0))
    (set! %known-cols (bytevector-u16-native-ref %winsize 2))))

(define* (terminal-size-changed? #:optional (fd 1))
  "Return #t if the tty's dimensions differ from the last synced size."
  (and %c-ioctl
       (zero? (%c-ioctl fd %tiocgwinsz (bytevector->pointer %winsize)))
       (or (not (= (bytevector-u16-native-ref %winsize 0) %known-rows))
           (not (= (bytevector-u16-native-ref %winsize 2) %known-cols)))))

(define %sleep-req (make-bytevector 16 0))

(define (sleep-ms ms)
  "Sleep for MS milliseconds using libc nanosleep."
  (when %c-nanosleep
    (bytevector-u64-native-set! %sleep-req 0 (quotient ms 1000))
    (bytevector-u64-native-set! %sleep-req 8 (* (remainder ms 1000) 1000000))
    (%c-nanosleep (bytevector->pointer %sleep-req) %null-pointer)))
