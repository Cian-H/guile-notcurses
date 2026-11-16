;;; notcurses/compat/curses.scm — Curses compatibility layer over (notcurses).
;;;
;;; Adapted from badb's (geasa surfaces-tui nc) module, layered on top of
;;; guile-notcurses's core, plane, input, struct, constant, and terminal
;;; modules.

(define-module (notcurses compat curses)
  #:use-module (rnrs bytevectors)
  #:use-module (system foreign)
  #:use-module (notcurses constants)
  #:use-module (notcurses structs)
  #:use-module (notcurses core)
  #:use-module (notcurses plane)
  #:use-module (notcurses input)
  #:use-module (notcurses terminal)
  #:export (initscr endwin cbreak! noecho! keypad! curs-set
            erase refresh getmaxy getmaxx move addstr getch
            attr-on! attr-off! has-colors? start-color! init-pair!
            color-pair nodelay! nodelay
            ERR
            A_BOLD A_DIM A_REVERSE
            KEY_ENTER KEY_BACKSPACE KEY_UP KEY_DOWN KEY_PPAGE KEY_NPAGE
            KEY_LEFT KEY_RIGHT KEY_HOME KEY_END KEY_DC KEY_RESIZE
            KEY_FIND KEY_OPEN
            key-defined define-key
            drain-mouse-events
            input-pending? drain-input-burst! pushback-count
            COLOR_BLACK COLOR_RED COLOR_GREEN COLOR_YELLOW
            COLOR_BLUE COLOR_MAGENTA COLOR_CYAN COLOR_WHITE)
  #:re-export (beep cursor-shape))

(define %u32-err 4294967295)

(define ERR -1)
(define A_BOLD #x10000)
(define A_DIM #x20000)
(define A_REVERSE #x40000)

;; Map curses KEY_* names to notcurses NCKEY_* constants
(define KEY_UP NCKEY_UP)
(define KEY_RIGHT NCKEY_RIGHT)
(define KEY_DOWN NCKEY_DOWN)
(define KEY_LEFT NCKEY_LEFT)
(define KEY_DC NCKEY_DEL)
(define KEY_BACKSPACE NCKEY_BACKSPACE)
(define KEY_NPAGE NCKEY_PGDOWN)
(define KEY_PPAGE NCKEY_PGUP)
(define KEY_HOME NCKEY_HOME)
(define KEY_END NCKEY_END)
(define KEY_ENTER NCKEY_ENTER)
(define KEY_RESIZE NCKEY_RESIZE)

;; Sentinels for Ctrl+Up/Ctrl+Down outside preterunicode range
(define KEY_FIND 2000000)
(define KEY_OPEN 2000001)

(define COLOR_BLACK 0)
(define COLOR_RED 1)
(define COLOR_GREEN 2)
(define COLOR_YELLOW 3)
(define COLOR_BLUE 4)
(define COLOR_MAGENTA 5)
(define COLOR_CYAN 6)
(define COLOR_WHITE 7)

(define %color-rgb
  #(#x000000 #xcd0000 #x00cd00 #xcdcd00
    #x0000cd #xcd00cd #x00cdcd #xe5e5e5))

(define %nc %null-pointer)
(define %plane %null-pointer)
(define %pairs (make-hash-table 61))
(define %fg 'default)
(define %bg 'default)
(define %nodelay? #f)
(define %dim? #f)
(define %cursor-visible? #f)
(define %cursor-y 0)
(define %cursor-x 0)
(define %next-y 0)
(define %next-x 0)

(define (dimmed-rgb rgb)
  (logand (ash rgb -1) #x7f7f7f))

(define %default-fg-slot (make-bytevector 4))
(define %default-bg-slot (make-bytevector 4))

(define (terminal-default-fg)
  (if (= (notcurses_default_foreground %nc (bytevector->pointer %default-fg-slot)) 0)
      (logand (bytevector-u32-native-ref %default-fg-slot 0) #xffffff)
      #xe5e5e5))

(define (terminal-default-bg)
  (if (= (notcurses_default_background %nc (bytevector->pointer %default-bg-slot)) 0)
      (logand (bytevector-u32-native-ref %default-bg-slot 0) #xffffff)
      #x000000))

(define (apply-foreground!)
  (cond
    ((and (eq? %fg 'default) (not %dim?)) (ncplane_set_fg_default %plane))
    ((eq? %fg 'default) (ncplane_set_fg_rgb %plane (dimmed-rgb (terminal-default-fg))))
    (%dim? (ncplane_set_fg_rgb %plane (dimmed-rgb %fg)))
    (else (ncplane_set_fg_rgb %plane %fg))))

(define (apply-background!)
  (if (eq? %bg 'default)
      (ncplane_set_bg_default %plane)
      (ncplane_set_bg_rgb %plane %bg)))

(define (apply-channels!)
  (apply-foreground!)
  (apply-background!))

(define* (initscr #:optional (stderr-log-path (if (file-exists? ".badb")
                                                  ".badb/tui-stderr.log"
                                                  "/dev/null")))
  (redirect-stderr-for-tui! stderr-log-path)
  (let ((opts (make-notcurses-options #:flags NCOPTION_SUPPRESS_BANNERS)))
    (set! %nc (notcurses_init (nc-struct-ptr opts) %null-pointer))
    (when (null-pointer? %nc)
      (error "notcurses_init failed"))
    (notcurses_mice_enable %nc NCMICE_BUTTON_EVENT)
    (set! %plane (notcurses_stdplane %nc))
    (set! %fg 'default)
    (set! %bg 'default)
    (set! %pairs (make-hash-table 61))
    (sync-known-size!)
    (drain-input!)
    %plane))

(define (endwin)
  (unless (null-pointer? %nc)
    (cursor-shape 'default)
    (notcurses_stop %nc)
    (set! %nc %null-pointer)
    (set! %plane %null-pointer)
    (restore-stderr-for-tui!)))

(define (cbreak!) #t)
(define (noecho!) #t)
(define (keypad! win enabled?) #t)
(define (has-colors?) #t)
(define (start-color!) #t)

(define %dim-y (make-bytevector 4))
(define %dim-x (make-bytevector 4))

(define (refresh-dims!)
  (ncplane_dim_yx %plane
                  (bytevector->pointer %dim-y)
                  (bytevector->pointer %dim-x)))

(define (getmaxy win) (refresh-dims!) (bytevector-u32-native-ref %dim-y 0))
(define (getmaxx win) (refresh-dims!) (bytevector-u32-native-ref %dim-x 0))

(define (move win y x)
  (set! %next-y y)
  (set! %next-x x)
  (set! %cursor-y y)
  (set! %cursor-x x)
  #t)

(define (addstr win str)
  (let ((y %next-y) (x %next-x))
    (when (and (>= y 0) (>= x 0))
      (ncplane_putstr_yx %plane y x (string->pointer str)))
    (set! %cursor-y y)
    (set! %cursor-x (+ x (string-length str)))
    #t))

(define (erase win) (ncplane_erase %plane) #t)

(define (refresh win)
  (let ((r (notcurses_render %nc)))
    (when %cursor-visible?
      (refresh-dims!)
      (let ((maxy (bytevector-u32-native-ref %dim-y 0))
            (maxx (bytevector-u32-native-ref %dim-x 0)))
        (set! %cursor-y (min (max %cursor-y 0) (- maxy 1)))
        (set! %cursor-x (min (max %cursor-x 0) (- maxx 1)))
        (notcurses_cursor_enable %nc %cursor-y %cursor-x)))
    r))

(define (curs-set visibility)
  (cond
    ((= visibility 0)
     (set! %cursor-visible? #f)
     (notcurses_cursor_disable %nc))
    (else
     (set! %cursor-visible? #t)
     (notcurses_cursor_enable %nc %cursor-y %cursor-x)))
  #t)

(define (init-pair! id fg bg)
  (hashv-set! %pairs id
              (cons (if (<= fg 7) (vector-ref %color-rgb fg) fg)
                    (if (<= bg 7) (vector-ref %color-rgb bg) bg)))
  #t)

(define (color-pair id) id)

(define (pair-background rgb)
  (if (= (cdr rgb) #x000000) 'default (cdr rgb)))

(define (attr-on! win attr)
  (cond
    ((eqv? attr A_BOLD) (ncplane_on_styles %plane NCSTYLE_BOLD))
    ((eqv? attr A_REVERSE)
     (let ((f (if (eq? %fg 'default) (terminal-default-fg) %fg))
           (b (if (eq? %bg 'default) (terminal-default-bg) %bg)))
       (set! %fg b)
       (set! %bg f)
       (apply-channels!)))
    ((eqv? attr A_DIM)
     (set! %dim? #t)
     (apply-foreground!))
    (else
     (let ((rgb (hashv-ref %pairs attr)))
       (when rgb
         (set! %fg (car rgb))
         (set! %bg (pair-background rgb))
         (apply-channels!)))))
  #t)

(define (attr-off! win attr)
  (cond
    ((eqv? attr A_BOLD) (ncplane_off_styles %plane NCSTYLE_BOLD))
    ((eqv? attr A_REVERSE)
     (let ((f %fg) (b %bg))
       (set! %fg b)
       (set! %bg f)
       (apply-channels!)))
    ((eqv? attr A_DIM)
     (set! %dim? #f)
     (apply-foreground!))
    (else
     (set! %fg 'default)
     (set! %bg 'default)
     (apply-channels!)))
  #t)

;;;
;;; Input & Paste Bursts
;;;
(define %ncinput (make-ncinput))
(define %ncinput-ptr (nc-struct-ptr %ncinput))
(define %pushback '())

(define (push-back-event! id)
  (let ((copy (make-ncinput)))
    (ncinput-copy! copy %ncinput)
    (set! %pushback (cons (cons id copy) %pushback))))

(define (pushback-count)
  (length %pushback))

(define (%discard-input-event?)
  (cond
    ((pair? %pushback)
     (set! %pushback (cdr %pushback))
     #t)
    ((null-pointer? %nc) #f)
    (else
     (let ((r (notcurses_get_nblock %nc %ncinput-ptr)))
       (not (or (= r 0) (= r %u32-err)))))))

(define (drain-input!)
  (let drain ((quiet 0))
    (let flush ()
      (when (%discard-input-event?) (flush)))
    (sleep-ms 50)
    (cond
      ((%discard-input-event?) (drain 0))
      ((< quiet 1) (drain (+ quiet 1)))
      (else #t))))

(define (input-modifiers) (ncinput-modifiers %ncinput))
(define (input-release?) (= (ncinput-evtype %ncinput) NCTYPE_RELEASE))
(define (input-ctrl?) (= (logand (input-modifiers) NCKEY_MOD_CTRL) NCKEY_MOD_CTRL))
(define (input-eff-text) (ncinput-eff-text-ref %ncinput 0))

(define (read-raw-id-nblock)
  (cond
    ((pair? %pushback)
     (let ((front (car %pushback)))
       (set! %pushback (cdr %pushback))
       (ncinput-copy! %ncinput (cdr front))
       (car front)))
    ((null-pointer? %nc) #f)
    (else
     (let ((r (notcurses_get_nblock %nc %ncinput-ptr)))
       (if (or (= r 0) (= r %u32-err)) #f r)))))

(define (read-raw-id)
  (if %nodelay?
      (read-raw-id-nblock)
      (let poll ()
        (cond
          ((read-raw-id-nblock))
          ((terminal-size-changed?) KEY_RESIZE)
          (else (sleep-ms 20) (poll))))))

(define %mouse-queue '())

(define (queue-mouse-event! id)
  (set! %mouse-queue
        (cons (list (- id NCKEY_BUTTON1 -1)
                    (ncinput-y %ncinput)
                    (ncinput-x %ncinput))
              %mouse-queue)))

(define (drain-mouse-events)
  (let ((events (reverse! %mouse-queue)))
    (set! %mouse-queue '())
    events))

(define %delivered-keys
  (list KEY_UP KEY_RIGHT KEY_DOWN KEY_LEFT KEY_DC KEY_BACKSPACE
        KEY_NPAGE KEY_PPAGE KEY_HOME KEY_END KEY_ENTER KEY_RESIZE
        KEY_FIND KEY_OPEN))

(define (%consume-non-key-event? id)
  (cond
    ((or (= id NCKEY_INVALID) (input-release?)) #t)
    ((and (>= id NCKEY_BUTTON1) (<= id NCKEY_BUTTON10))
     (queue-mouse-event! id)
     #t)
    ((and (>= id NCKEY_INVALID) (not (memv id %delivered-keys))) #t)
    (else #f)))

(define (input-pending?)
  (let loop ()
    (let ((id (read-raw-id-nblock)))
      (cond
        ((not id) #f)
        ((%consume-non-key-event? id) (loop))
        (else (push-back-event! id) #t)))))

(define (translate-key-id id)
  "Translate a deliverable raw notcurses key ID into a curses key code."
  (cond
    ((and (= id KEY_UP) (input-ctrl?)) KEY_FIND)
    ((and (= id KEY_DOWN) (input-ctrl?)) KEY_OPEN)
    ((= id KEY_RESIZE)
     (catch #t
       (lambda ()
         (notcurses_refresh %nc %null-pointer %null-pointer)
         (sync-known-size!))
       (lambda _ #f))
     KEY_RESIZE)
    ((and (input-ctrl?)
          (or (and (>= id 97) (<= id 122)) (and (>= id 65) (<= id 90))))
     (if (< id 97) (- id 64) (- id 96)))
    ((and (not (input-ctrl?))
          (>= id 32)
          (< id NCKEY_INVALID)
          (> (input-eff-text) 0))
     (input-eff-text))
    (else id)))

(define (getch win)
  (let loop ((id (read-raw-id)))
    (cond
      ((or (not id) (= id 0) (= id %u32-err)) ERR)
      ((%consume-non-key-event? id)
       (if (and (>= id NCKEY_BUTTON1) (<= id NCKEY_BUTTON10) (not (input-release?)))
           ERR
           (loop (read-raw-id))))
      (else (translate-key-id id)))))

(define (%burst-payload-codepoint id)
  (cond
    ((or (= id 10) (= id 13)) id)
    ((and (>= id 32)
          (< id NCKEY_INVALID)
          (not (input-ctrl?)))
     (let ((eff (input-eff-text)))
       (if (> eff 0) eff id)))
    (else #f)))

(define (drain-input-burst!)
  (let loop ((acc '()) (slept? #f))
    (let ((id (read-raw-id-nblock)))
      (cond
        ((not id)
         (if (or slept? (null? acc))
             (reverse! acc)
             (begin (sleep-ms 4) (loop acc #t))))
        ((%consume-non-key-event? id) (loop acc #f))
        (else
         (let ((cp (%burst-payload-codepoint id)))
           (if cp
               (loop (cons cp acc) #f)
               (begin (push-back-event! id) (reverse! acc)))))))))

(define (nodelay! win enabled?)
  (set! %nodelay? (if enabled? #t #f))
  #t)
(define nodelay nodelay!)

(define (key-defined seq)
  (cond
    ((string=? seq "\x1b[1;5A") KEY_FIND)
    ((string=? seq "\x1b[1;5B") KEY_OPEN)
    (else #f)))

(define (define-key seq code) #t)
