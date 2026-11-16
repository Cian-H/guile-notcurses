;;; notcurses/structs.scm — Bytevector-backed C struct wrappers for notcurses 3.x.
;;;
;;; All struct sizes and field offsets are verified against notcurses 3.0.16
;;; headers on x86_64 Linux. Each wrapper holds a bytevector, its cached
;;; pointer, and a GC-retention vector for referenced pointers/strings so
;;; Scheme strings passed into options structs are never collected prematurely.

(define-module (notcurses structs)
  #:use-module (srfi srfi-9)
  #:use-module (rnrs bytevectors)
  #:use-module (system foreign)
  #:export (<nc-struct>
            nc-struct?
            nc-struct-bv
            nc-struct-ptr
            ->pointer
            ;; notcurses_options
            make-notcurses-options
            notcurses-options-termtype notcurses-options-set-termtype!
            notcurses-options-loglevel notcurses-options-set-loglevel!
            notcurses-options-margin-t notcurses-options-set-margin-t!
            notcurses-options-margin-r notcurses-options-set-margin-r!
            notcurses-options-margin-b notcurses-options-set-margin-b!
            notcurses-options-margin-l notcurses-options-set-margin-l!
            notcurses-options-flags notcurses-options-set-flags!
            ;; ncplane_options
            make-ncplane-options
            ncplane-options-y ncplane-options-set-y!
            ncplane-options-x ncplane-options-set-x!
            ncplane-options-rows ncplane-options-set-rows!
            ncplane-options-cols ncplane-options-set-cols!
            ncplane-options-userptr ncplane-options-set-userptr!
            ncplane-options-name ncplane-options-set-name!
            ncplane-options-resizecb ncplane-options-set-resizecb!
            ncplane-options-flags ncplane-options-set-flags!
            ncplane-options-margin-b ncplane-options-set-margin-b!
            ncplane-options-margin-r ncplane-options-set-margin-r!
            ;; nccell
            make-nccell
            nccell-gcluster nccell-set-gcluster!
            nccell-gcluster-backstop nccell-set-gcluster-backstop!
            nccell-width nccell-set-width!
            nccell-stylemask nccell-set-stylemask!
            nccell-channels nccell-set-channels!
            ;; ncinput
            make-ncinput
            ncinput-copy!
            ncinput-id ncinput-set-id!
            ncinput-y ncinput-set-y!
            ncinput-x ncinput-set-x!
            ncinput-utf8
            ncinput-alt ncinput-shift ncinput-ctrl
            ncinput-evtype ncinput-set-evtype!
            ncinput-modifiers ncinput-set-modifiers!
            ncinput-ypx ncinput-xpx
            ncinput-eff-text-ref
            ;; ncvisual_options
            make-ncvisual-options
            ncvisual-options-n ncvisual-options-set-n!
            ncvisual-options-scaling ncvisual-options-set-scaling!
            ncvisual-options-y ncvisual-options-set-y!
            ncvisual-options-x ncvisual-options-set-x!
            ncvisual-options-begy ncvisual-options-set-begy!
            ncvisual-options-begx ncvisual-options-set-begx!
            ncvisual-options-leny ncvisual-options-set-leny!
            ncvisual-options-lenx ncvisual-options-set-lenx!
            ncvisual-options-blitter ncvisual-options-set-blitter!
            ncvisual-options-flags ncvisual-options-set-flags!
            ncvisual-options-transcolor ncvisual-options-set-transcolor!
            ncvisual-options-pxoffy ncvisual-options-set-pxoffy!
            ncvisual-options-pxoffx ncvisual-options-set-pxoffx!
            ;; ncvgeom
            make-ncvgeom
            ncvgeom-pixy ncvgeom-pixx
            ncvgeom-cdimy ncvgeom-cdimx
            ncvgeom-rpixy ncvgeom-rpixx
            ncvgeom-rcelly ncvgeom-rcellx
            ncvgeom-scaley ncvgeom-scalex
            ncvgeom-begy ncvgeom-begx
            ncvgeom-leny ncvgeom-lenx
            ncvgeom-maxpixely ncvgeom-maxpixelx
            ncvgeom-blitter
            ;; nccapabilities
            make-nccapabilities
            nccapabilities-colors
            nccapabilities-utf8?
            nccapabilities-rgb?
            nccapabilities-can-change-colors?
            nccapabilities-halfblocks?
            nccapabilities-quadrants?
            nccapabilities-sextants?
            nccapabilities-octants?
            nccapabilities-braille?
            ;; ncpalette
            make-ncpalette
            ncpalette-chans-ref ncpalette-chans-set!
            ;; ncstats
            make-ncstats
            ncstats-renders ncstats-writeouts
            ncstats-failed-renders ncstats-failed-writeouts
            ncstats-raster-bytes ncstats-raster-max-bytes ncstats-raster-min-bytes
            ncstats-render-ns ncstats-render-max-ns ncstats-render-min-ns
            ncstats-raster-ns ncstats-raster-max-ns ncstats-raster-min-ns
            ncstats-writeout-ns ncstats-writeout-max-ns ncstats-writeout-min-ns
            ncstats-cellelisions ncstats-cellemissions
            ncstats-fgelisions ncstats-fgemissions
            ncstats-bgelisions ncstats-bgemissions
            ncstats-defaultelisions ncstats-defaultemissions
            ncstats-refreshes
            ncstats-sprixelemissions ncstats-sprixelelisions ncstats-sprixelbytes
            ncstats-appsync-updates ncstats-input-errors ncstats-input-events
            ncstats-hpa-gratuitous ncstats-cell-geo-changes ncstats-pixel-geo-changes
            ncstats-fbbytes ncstats-planes
            ;; Widget options & items
            make-ncmenu-item make-ncmenu-section make-ncmenu-options
            make-ncselector-item make-ncselector-options
            make-ncmselector-item ncmselector-item-selected?
            make-ncmultiselector-options
            make-ncreader-options
            make-nctree-item make-nctree-options
            make-ncprogbar-options
            make-nctabbed-options
            make-ncplot-options
            make-ncreel-options
            make-ncfdplane-options
            make-ncsubproc-options))

(define-record-type <nc-struct>
  (%make-nc-struct tag bv ptr refs)
  nc-struct?
  (tag nc-struct-tag)
  (bv nc-struct-bv)
  (ptr nc-struct-ptr)
  (refs nc-struct-refs))

(define (alloc-struct tag size ref-slots)
  (let ((bv (make-bytevector size 0)))
    (%make-nc-struct tag bv (bytevector->pointer bv) (make-vector ref-slots #f))))

(define (->pointer x)
  "Convert an <nc-struct>, bytevector, foreign pointer, or #f to a C pointer."
  (cond
    ((not x) %null-pointer)
    ((nc-struct? x) (nc-struct-ptr x))
    ((bytevector? x) (bytevector->pointer x))
    ((pointer? x) x)
    (else (error "Expected <nc-struct>, bytevector, pointer, or #f" x))))

(define (set-ptr-field! st offset ref-idx val)
  (let* ((bv (nc-struct-bv st))
         (refs (nc-struct-refs st))
         (ptr (cond
                ((not val)
                 (vector-set! refs ref-idx #f)
                 %null-pointer)
                ((string? val)
                 (let ((p (string->pointer val)))
                   (vector-set! refs ref-idx (cons val p))
                   p))
                ((nc-struct? val)
                 (vector-set! refs ref-idx val)
                 (nc-struct-ptr val))
                ((bytevector? val)
                 (vector-set! refs ref-idx val)
                 (bytevector->pointer val))
                ((pointer? val)
                 (vector-set! refs ref-idx val)
                 val)
                (else (error "Invalid pointer field value" val)))))
    (bytevector-u64-native-set! bv offset (pointer-address ptr))))

(define (get-ptr-field st offset)
  (let ((addr (bytevector-u64-native-ref (nc-struct-bv st) offset)))
    (if (zero? addr) %null-pointer (make-pointer addr))))

(define (get-str-field st offset)
  (let ((p (get-ptr-field st offset)))
    (if (null-pointer? p) #f (pointer->string p))))

;;;
;;; notcurses_options (40 bytes)
;;;
(define* (make-notcurses-options #:key (termtype #f) (loglevel 0)
                                 (margin-t 0) (margin-r 0)
                                 (margin-b 0) (margin-l 0)
                                 (flags 0))
  (let ((st (alloc-struct 'notcurses_options 40 1)))
    (when termtype (notcurses-options-set-termtype! st termtype))
    (notcurses-options-set-loglevel! st loglevel)
    (notcurses-options-set-margin-t! st margin-t)
    (notcurses-options-set-margin-r! st margin-r)
    (notcurses-options-set-margin-b! st margin-b)
    (notcurses-options-set-margin-l! st margin-l)
    (notcurses-options-set-flags! st flags)
    st))

(define (notcurses-options-termtype st) (get-str-field st 0))
(define (notcurses-options-set-termtype! st v) (set-ptr-field! st 0 0 v))
(define (notcurses-options-loglevel st) (bytevector-s32-native-ref (nc-struct-bv st) 8))
(define (notcurses-options-set-loglevel! st v) (bytevector-s32-native-set! (nc-struct-bv st) 8 v))
(define (notcurses-options-margin-t st) (bytevector-u32-native-ref (nc-struct-bv st) 12))
(define (notcurses-options-set-margin-t! st v) (bytevector-u32-native-set! (nc-struct-bv st) 12 v))
(define (notcurses-options-margin-r st) (bytevector-u32-native-ref (nc-struct-bv st) 16))
(define (notcurses-options-set-margin-r! st v) (bytevector-u32-native-set! (nc-struct-bv st) 16 v))
(define (notcurses-options-margin-b st) (bytevector-u32-native-ref (nc-struct-bv st) 20))
(define (notcurses-options-set-margin-b! st v) (bytevector-u32-native-set! (nc-struct-bv st) 20 v))
(define (notcurses-options-margin-l st) (bytevector-u32-native-ref (nc-struct-bv st) 24))
(define (notcurses-options-set-margin-l! st v) (bytevector-u32-native-set! (nc-struct-bv st) 24 v))
(define (notcurses-options-flags st) (bytevector-u64-native-ref (nc-struct-bv st) 32))
(define (notcurses-options-set-flags! st v) (bytevector-u64-native-set! (nc-struct-bv st) 32 v))

;;;
;;; ncplane_options (56 bytes)
;;;
(define* (make-ncplane-options #:key (y 0) (x 0) (rows 0) (cols 0)
                               (userptr #f) (name #f) (resizecb #f)
                               (flags 0) (margin-b 0) (margin-r 0))
  (let ((st (alloc-struct 'ncplane_options 56 3)))
    (ncplane-options-set-y! st y)
    (ncplane-options-set-x! st x)
    (ncplane-options-set-rows! st rows)
    (ncplane-options-set-cols! st cols)
    (when userptr (ncplane-options-set-userptr! st userptr))
    (when name (ncplane-options-set-name! st name))
    (when resizecb (ncplane-options-set-resizecb! st resizecb))
    (ncplane-options-set-flags! st flags)
    (ncplane-options-set-margin-b! st margin-b)
    (ncplane-options-set-margin-r! st margin-r)
    st))

(define (ncplane-options-y st) (bytevector-s32-native-ref (nc-struct-bv st) 0))
(define (ncplane-options-set-y! st v) (bytevector-s32-native-set! (nc-struct-bv st) 0 v))
(define (ncplane-options-x st) (bytevector-s32-native-ref (nc-struct-bv st) 4))
(define (ncplane-options-set-x! st v) (bytevector-s32-native-set! (nc-struct-bv st) 4 v))
(define (ncplane-options-rows st) (bytevector-u32-native-ref (nc-struct-bv st) 8))
(define (ncplane-options-set-rows! st v) (bytevector-u32-native-set! (nc-struct-bv st) 8 v))
(define (ncplane-options-cols st) (bytevector-u32-native-ref (nc-struct-bv st) 12))
(define (ncplane-options-set-cols! st v) (bytevector-u32-native-set! (nc-struct-bv st) 12 v))
(define (ncplane-options-userptr st) (get-ptr-field st 16))
(define (ncplane-options-set-userptr! st v) (set-ptr-field! st 16 0 v))
(define (ncplane-options-name st) (get-str-field st 24))
(define (ncplane-options-set-name! st v) (set-ptr-field! st 24 1 v))
(define (ncplane-options-resizecb st) (get-ptr-field st 32))
(define (ncplane-options-set-resizecb! st v) (set-ptr-field! st 32 2 v))
(define (ncplane-options-flags st) (bytevector-u64-native-ref (nc-struct-bv st) 40))
(define (ncplane-options-set-flags! st v) (bytevector-u64-native-set! (nc-struct-bv st) 40 v))
(define (ncplane-options-margin-b st) (bytevector-u32-native-ref (nc-struct-bv st) 48))
(define (ncplane-options-set-margin-b! st v) (bytevector-u32-native-set! (nc-struct-bv st) 48 v))
(define (ncplane-options-margin-r st) (bytevector-u32-native-ref (nc-struct-bv st) 52))
(define (ncplane-options-set-margin-r! st v) (bytevector-u32-native-set! (nc-struct-bv st) 52 v))

;;;
;;; nccell (16 bytes)
;;;
(define (make-nccell) (alloc-struct 'nccell 16 0))
(define (nccell-gcluster st) (bytevector-u32-native-ref (nc-struct-bv st) 0))
(define (nccell-set-gcluster! st v) (bytevector-u32-native-set! (nc-struct-bv st) 0 v))
(define (nccell-gcluster-backstop st) (bytevector-u8-ref (nc-struct-bv st) 4))
(define (nccell-set-gcluster-backstop! st v) (bytevector-u8-set! (nc-struct-bv st) 4 v))
(define (nccell-width st) (bytevector-u8-ref (nc-struct-bv st) 5))
(define (nccell-set-width! st v) (bytevector-u8-set! (nc-struct-bv st) 5 v))
(define (nccell-stylemask st) (bytevector-u16-native-ref (nc-struct-bv st) 6))
(define (nccell-set-stylemask! st v) (bytevector-u16-native-set! (nc-struct-bv st) 6 v))
(define (nccell-channels st) (bytevector-u64-native-ref (nc-struct-bv st) 8))
(define (nccell-set-channels! st v) (bytevector-u64-native-set! (nc-struct-bv st) 8 v))

;;;
;;; ncinput (52 bytes)
;;;
(define (make-ncinput) (alloc-struct 'ncinput 52 0))

(define (ncinput-copy! dst src)
  (bytevector-copy! (nc-struct-bv src) 0 (nc-struct-bv dst) 0 52))

(define (ncinput-id st) (bytevector-u32-native-ref (nc-struct-bv st) 0))
(define (ncinput-set-id! st v) (bytevector-u32-native-set! (nc-struct-bv st) 0 v))
(define (ncinput-y st) (bytevector-s32-native-ref (nc-struct-bv st) 4))
(define (ncinput-set-y! st v) (bytevector-s32-native-set! (nc-struct-bv st) 4 v))
(define (ncinput-x st) (bytevector-s32-native-ref (nc-struct-bv st) 8))
(define (ncinput-set-x! st v) (bytevector-s32-native-set! (nc-struct-bv st) 8 v))
(define (ncinput-utf8 st)
  (let* ((bv (nc-struct-bv st))
         (bytes (let loop ((i 0) (acc '()))
                  (if (= i 5)
                      (reverse acc)
                      (let ((b (bytevector-u8-ref bv (+ 12 i))))
                        (if (zero? b)
                            (reverse acc)
                            (loop (+ i 1) (cons b acc))))))))
    (utf8->string (u8-list->bytevector bytes))))
(define (ncinput-alt st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 17))))
(define (ncinput-shift st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 18))))
(define (ncinput-ctrl st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 19))))
(define (ncinput-evtype st) (bytevector-s32-native-ref (nc-struct-bv st) 20))
(define (ncinput-set-evtype! st v) (bytevector-s32-native-set! (nc-struct-bv st) 20 v))
(define (ncinput-modifiers st) (bytevector-u32-native-ref (nc-struct-bv st) 24))
(define (ncinput-set-modifiers! st v) (bytevector-u32-native-set! (nc-struct-bv st) 24 v))
(define (ncinput-ypx st) (bytevector-s32-native-ref (nc-struct-bv st) 28))
(define (ncinput-xpx st) (bytevector-s32-native-ref (nc-struct-bv st) 32))
(define* (ncinput-eff-text-ref st #:optional (idx 0))
  (bytevector-u32-native-ref (nc-struct-bv st) (+ 36 (* idx 4))))

;;;
;;; ncvisual_options (64 bytes)
;;;
(define* (make-ncvisual-options #:key (n #f) (scaling 0) (y 0) (x 0)
                                (begy 0) (begx 0) (leny 0) (lenx 0)
                                (blitter 0) (flags 0) (transcolor 0)
                                (pxoffy 0) (pxoffx 0))
  (let ((st (alloc-struct 'ncvisual_options 64 1)))
    (when n (ncvisual-options-set-n! st n))
    (ncvisual-options-set-scaling! st scaling)
    (ncvisual-options-set-y! st y)
    (ncvisual-options-set-x! st x)
    (ncvisual-options-set-begy! st begy)
    (ncvisual-options-set-begx! st begx)
    (ncvisual-options-set-leny! st leny)
    (ncvisual-options-set-lenx! st lenx)
    (ncvisual-options-set-blitter! st blitter)
    (ncvisual-options-set-flags! st flags)
    (ncvisual-options-set-transcolor! st transcolor)
    (ncvisual-options-set-pxoffy! st pxoffy)
    (ncvisual-options-set-pxoffx! st pxoffx)
    st))

(define (ncvisual-options-n st) (get-ptr-field st 0))
(define (ncvisual-options-set-n! st v) (set-ptr-field! st 0 0 v))
(define (ncvisual-options-scaling st) (bytevector-s32-native-ref (nc-struct-bv st) 8))
(define (ncvisual-options-set-scaling! st v) (bytevector-s32-native-set! (nc-struct-bv st) 8 v))
(define (ncvisual-options-y st) (bytevector-s32-native-ref (nc-struct-bv st) 12))
(define (ncvisual-options-set-y! st v) (bytevector-s32-native-set! (nc-struct-bv st) 12 v))
(define (ncvisual-options-x st) (bytevector-s32-native-ref (nc-struct-bv st) 16))
(define (ncvisual-options-set-x! st v) (bytevector-s32-native-set! (nc-struct-bv st) 16 v))
(define (ncvisual-options-begy st) (bytevector-u32-native-ref (nc-struct-bv st) 20))
(define (ncvisual-options-set-begy! st v) (bytevector-u32-native-set! (nc-struct-bv st) 20 v))
(define (ncvisual-options-begx st) (bytevector-u32-native-ref (nc-struct-bv st) 24))
(define (ncvisual-options-set-begx! st v) (bytevector-u32-native-set! (nc-struct-bv st) 24 v))
(define (ncvisual-options-leny st) (bytevector-u32-native-ref (nc-struct-bv st) 28))
(define (ncvisual-options-set-leny! st v) (bytevector-u32-native-set! (nc-struct-bv st) 28 v))
(define (ncvisual-options-lenx st) (bytevector-u32-native-ref (nc-struct-bv st) 32))
(define (ncvisual-options-set-lenx! st v) (bytevector-u32-native-set! (nc-struct-bv st) 32 v))
(define (ncvisual-options-blitter st) (bytevector-s32-native-ref (nc-struct-bv st) 36))
(define (ncvisual-options-set-blitter! st v) (bytevector-s32-native-set! (nc-struct-bv st) 36 v))
(define (ncvisual-options-flags st) (bytevector-u64-native-ref (nc-struct-bv st) 40))
(define (ncvisual-options-set-flags! st v) (bytevector-u64-native-set! (nc-struct-bv st) 40 v))
(define (ncvisual-options-transcolor st) (bytevector-u32-native-ref (nc-struct-bv st) 48))
(define (ncvisual-options-set-transcolor! st v) (bytevector-u32-native-set! (nc-struct-bv st) 48 v))
(define (ncvisual-options-pxoffy st) (bytevector-u32-native-ref (nc-struct-bv st) 52))
(define (ncvisual-options-set-pxoffy! st v) (bytevector-u32-native-set! (nc-struct-bv st) 52 v))
(define (ncvisual-options-pxoffx st) (bytevector-u32-native-ref (nc-struct-bv st) 56))
(define (ncvisual-options-set-pxoffx! st v) (bytevector-u32-native-set! (nc-struct-bv st) 56 v))

;;;
;;; ncvgeom (68 bytes)
;;;
(define (make-ncvgeom) (alloc-struct 'ncvgeom 68 0))
(define (ncvgeom-pixy st) (bytevector-u32-native-ref (nc-struct-bv st) 0))
(define (ncvgeom-pixx st) (bytevector-u32-native-ref (nc-struct-bv st) 4))
(define (ncvgeom-cdimy st) (bytevector-u32-native-ref (nc-struct-bv st) 8))
(define (ncvgeom-cdimx st) (bytevector-u32-native-ref (nc-struct-bv st) 12))
(define (ncvgeom-rpixy st) (bytevector-u32-native-ref (nc-struct-bv st) 16))
(define (ncvgeom-rpixx st) (bytevector-u32-native-ref (nc-struct-bv st) 20))
(define (ncvgeom-rcelly st) (bytevector-u32-native-ref (nc-struct-bv st) 24))
(define (ncvgeom-rcellx st) (bytevector-u32-native-ref (nc-struct-bv st) 28))
(define (ncvgeom-scaley st) (bytevector-u32-native-ref (nc-struct-bv st) 32))
(define (ncvgeom-scalex st) (bytevector-u32-native-ref (nc-struct-bv st) 36))
(define (ncvgeom-begy st) (bytevector-u32-native-ref (nc-struct-bv st) 40))
(define (ncvgeom-begx st) (bytevector-u32-native-ref (nc-struct-bv st) 44))
(define (ncvgeom-leny st) (bytevector-u32-native-ref (nc-struct-bv st) 48))
(define (ncvgeom-lenx st) (bytevector-u32-native-ref (nc-struct-bv st) 52))
(define (ncvgeom-maxpixely st) (bytevector-u32-native-ref (nc-struct-bv st) 56))
(define (ncvgeom-maxpixelx st) (bytevector-u32-native-ref (nc-struct-bv st) 60))
(define (ncvgeom-blitter st) (bytevector-s32-native-ref (nc-struct-bv st) 64))

;;;
;;; nccapabilities (12 bytes)
;;;
(define (make-nccapabilities) (alloc-struct 'nccapabilities 12 0))
(define (nccapabilities-colors st) (bytevector-u32-native-ref (nc-struct-bv st) 0))
(define (nccapabilities-utf8? st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 4))))
(define (nccapabilities-rgb? st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 5))))
(define (nccapabilities-can-change-colors? st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 6))))
(define (nccapabilities-halfblocks? st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 7))))
(define (nccapabilities-quadrants? st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 8))))
(define (nccapabilities-sextants? st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 9))))
(define (nccapabilities-octants? st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 10))))
(define (nccapabilities-braille? st) (not (zero? (bytevector-u8-ref (nc-struct-bv st) 11))))

;;;
;;; ncpalette (1024 bytes: uint32_t chans[256])
;;;
(define (make-ncpalette) (alloc-struct 'ncpalette 1024 0))
(define (ncpalette-chans-ref st idx) (bytevector-u32-native-ref (nc-struct-bv st) (* idx 4)))
(define (ncpalette-chans-set! st idx val) (bytevector-u32-native-set! (nc-struct-bv st) (* idx 4) val))

;;;
;;; ncstats (288 bytes)
;;;
(define (make-ncstats) (alloc-struct 'ncstats 288 0))
(define (ncstats-renders st) (bytevector-u64-native-ref (nc-struct-bv st) 0))
(define (ncstats-writeouts st) (bytevector-u64-native-ref (nc-struct-bv st) 8))
(define (ncstats-failed-renders st) (bytevector-u64-native-ref (nc-struct-bv st) 16))
(define (ncstats-failed-writeouts st) (bytevector-u64-native-ref (nc-struct-bv st) 24))
(define (ncstats-raster-bytes st) (bytevector-u64-native-ref (nc-struct-bv st) 32))
(define (ncstats-raster-max-bytes st) (bytevector-u64-native-ref (nc-struct-bv st) 40))
(define (ncstats-raster-min-bytes st) (bytevector-u64-native-ref (nc-struct-bv st) 48))
(define (ncstats-render-ns st) (bytevector-u64-native-ref (nc-struct-bv st) 56))
(define (ncstats-render-max-ns st) (bytevector-u64-native-ref (nc-struct-bv st) 64))
(define (ncstats-render-min-ns st) (bytevector-u64-native-ref (nc-struct-bv st) 72))
(define (ncstats-raster-ns st) (bytevector-u64-native-ref (nc-struct-bv st) 80))
(define (ncstats-raster-max-ns st) (bytevector-u64-native-ref (nc-struct-bv st) 88))
(define (ncstats-raster-min-ns st) (bytevector-u64-native-ref (nc-struct-bv st) 96))
(define (ncstats-writeout-ns st) (bytevector-u64-native-ref (nc-struct-bv st) 104))
(define (ncstats-writeout-max-ns st) (bytevector-u64-native-ref (nc-struct-bv st) 112))
(define (ncstats-writeout-min-ns st) (bytevector-u64-native-ref (nc-struct-bv st) 120))
(define (ncstats-cellelisions st) (bytevector-u64-native-ref (nc-struct-bv st) 128))
(define (ncstats-cellemissions st) (bytevector-u64-native-ref (nc-struct-bv st) 136))
(define (ncstats-fgelisions st) (bytevector-u64-native-ref (nc-struct-bv st) 144))
(define (ncstats-fgemissions st) (bytevector-u64-native-ref (nc-struct-bv st) 152))
(define (ncstats-bgelisions st) (bytevector-u64-native-ref (nc-struct-bv st) 160))
(define (ncstats-bgemissions st) (bytevector-u64-native-ref (nc-struct-bv st) 168))
(define (ncstats-defaultelisions st) (bytevector-u64-native-ref (nc-struct-bv st) 176))
(define (ncstats-defaultemissions st) (bytevector-u64-native-ref (nc-struct-bv st) 184))
(define (ncstats-refreshes st) (bytevector-u64-native-ref (nc-struct-bv st) 192))
(define (ncstats-sprixelemissions st) (bytevector-u64-native-ref (nc-struct-bv st) 200))
(define (ncstats-sprixelelisions st) (bytevector-u64-native-ref (nc-struct-bv st) 208))
(define (ncstats-sprixelbytes st) (bytevector-u64-native-ref (nc-struct-bv st) 216))
(define (ncstats-appsync-updates st) (bytevector-u64-native-ref (nc-struct-bv st) 224))
(define (ncstats-input-errors st) (bytevector-u64-native-ref (nc-struct-bv st) 232))
(define (ncstats-input-events st) (bytevector-u64-native-ref (nc-struct-bv st) 240))
(define (ncstats-hpa-gratuitous st) (bytevector-u64-native-ref (nc-struct-bv st) 248))
(define (ncstats-cell-geo-changes st) (bytevector-u64-native-ref (nc-struct-bv st) 256))
(define (ncstats-pixel-geo-changes st) (bytevector-u64-native-ref (nc-struct-bv st) 264))
(define (ncstats-fbbytes st) (bytevector-u64-native-ref (nc-struct-bv st) 272))
(define (ncstats-planes st) (bytevector-u32-native-ref (nc-struct-bv st) 280))

;;;
;;; Widget options & items
;;;
(define* (make-ncmenu-item #:key (desc #f) (shortcut #f))
  (let ((st (alloc-struct 'ncmenu_item 64 1)))
    (when desc (set-ptr-field! st 0 0 desc))
    (when shortcut
      (bytevector-copy! (nc-struct-bv shortcut) 0 (nc-struct-bv st) 8 52))
    st))

(define* (make-ncmenu-section #:key (name #f) (itemcount 0) (items #f) (shortcut #f))
  (let ((st (alloc-struct 'ncmenu_section 80 2)))
    (when name (set-ptr-field! st 0 0 name))
    (bytevector-s32-native-set! (nc-struct-bv st) 8 itemcount)
    (when items (set-ptr-field! st 16 1 items))
    (when shortcut
      (bytevector-copy! (nc-struct-bv shortcut) 0 (nc-struct-bv st) 24 52))
    st))

(define* (make-ncmenu-options #:key (sections #f) (sectioncount 0)
                              (headerchannels 0) (sectionchannels 0) (flags 0))
  (let ((st (alloc-struct 'ncmenu_options 40 1)))
    (when sections (set-ptr-field! st 0 0 sections))
    (bytevector-s32-native-set! (nc-struct-bv st) 8 sectioncount)
    (bytevector-u64-native-set! (nc-struct-bv st) 16 headerchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 24 sectionchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 32 flags)
    st))

(define* (make-ncselector-item #:key (option #f) (desc #f))
  (let ((st (alloc-struct 'ncselector_item 16 2)))
    (when option (set-ptr-field! st 0 0 option))
    (when desc (set-ptr-field! st 8 1 desc))
    st))

(define* (make-ncselector-options #:key (title #f) (secondary #f) (footer #f)
                                  (items #f) (defidx 0) (maxdisplay 0)
                                  (opchannels 0) (descchannels 0)
                                  (titlechannels 0) (footchannels 0)
                                  (boxchannels 0) (flags 0))
  (let ((st (alloc-struct 'ncselector_options 88 4)))
    (when title (set-ptr-field! st 0 0 title))
    (when secondary (set-ptr-field! st 8 1 secondary))
    (when footer (set-ptr-field! st 16 2 footer))
    (when items (set-ptr-field! st 24 3 items))
    (bytevector-u32-native-set! (nc-struct-bv st) 32 defidx)
    (bytevector-u32-native-set! (nc-struct-bv st) 36 maxdisplay)
    (bytevector-u64-native-set! (nc-struct-bv st) 40 opchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 48 descchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 56 titlechannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 64 footchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 72 boxchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 80 flags)
    st))

(define* (make-ncmselector-item #:key (option #f) (desc #f) (selected? #f))
  (let ((st (alloc-struct 'ncmselector_item 24 2)))
    (when option (set-ptr-field! st 0 0 option))
    (when desc (set-ptr-field! st 8 1 desc))
    (bytevector-u8-set! (nc-struct-bv st) 16 (if selected? 1 0))
    st))

(define (ncmselector-item-selected? st)
  (not (zero? (bytevector-u8-ref (nc-struct-bv st) 16))))

(define* (make-ncmultiselector-options #:key (title #f) (secondary #f) (footer #f)
                                       (items #f) (maxdisplay 0)
                                       (opchannels 0) (descchannels 0)
                                       (titlechannels 0) (footchannels 0)
                                       (boxchannels 0) (flags 0))
  (let ((st (alloc-struct 'ncmultiselector_options 88 4)))
    (when title (set-ptr-field! st 0 0 title))
    (when secondary (set-ptr-field! st 8 1 secondary))
    (when footer (set-ptr-field! st 16 2 footer))
    (when items (set-ptr-field! st 24 3 items))
    (bytevector-u32-native-set! (nc-struct-bv st) 32 maxdisplay)
    (bytevector-u64-native-set! (nc-struct-bv st) 40 opchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 48 descchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 56 titlechannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 64 footchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 72 boxchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 80 flags)
    st))

(define* (make-ncreader-options #:key (tchannels 0) (tattrword 0) (flags 0))
  (let ((st (alloc-struct 'ncreader_options 24 0)))
    (bytevector-u64-native-set! (nc-struct-bv st) 0 tchannels)
    (bytevector-u32-native-set! (nc-struct-bv st) 8 tattrword)
    (bytevector-u64-native-set! (nc-struct-bv st) 16 flags)
    st))

(define* (make-nctree-item #:key (curry #f) (subs #f) (subcount 0))
  (let ((st (alloc-struct 'nctree_item 24 2)))
    (when curry (set-ptr-field! st 0 0 curry))
    (when subs (set-ptr-field! st 8 1 subs))
    (bytevector-u32-native-set! (nc-struct-bv st) 16 subcount)
    st))

(define* (make-nctree-options #:key (items #f) (count 0) (nctreecb #f)
                              (indentcols 0) (flags 0))
  (let ((st (alloc-struct 'nctree_options 40 2)))
    (when items (set-ptr-field! st 0 0 items))
    (bytevector-u32-native-set! (nc-struct-bv st) 8 count)
    (when nctreecb (set-ptr-field! st 16 1 nctreecb))
    (bytevector-s32-native-set! (nc-struct-bv st) 24 indentcols)
    (bytevector-u64-native-set! (nc-struct-bv st) 32 flags)
    st))

(define* (make-ncprogbar-options #:key (ulchannel 0) (urchannel 0)
                                 (blchannel 0) (brchannel 0) (flags 0))
  (let ((st (alloc-struct 'ncprogbar_options 24 0)))
    (bytevector-u32-native-set! (nc-struct-bv st) 0 ulchannel)
    (bytevector-u32-native-set! (nc-struct-bv st) 4 urchannel)
    (bytevector-u32-native-set! (nc-struct-bv st) 8 blchannel)
    (bytevector-u32-native-set! (nc-struct-bv st) 12 brchannel)
    (bytevector-u64-native-set! (nc-struct-bv st) 16 flags)
    st))

(define* (make-nctabbed-options #:key (selchan 0) (hdrchan 0) (sepchan 0)
                                (separator #f) (flags 0))
  (let ((st (alloc-struct 'nctabbed_options 40 1)))
    (bytevector-u64-native-set! (nc-struct-bv st) 0 selchan)
    (bytevector-u64-native-set! (nc-struct-bv st) 8 hdrchan)
    (bytevector-u64-native-set! (nc-struct-bv st) 16 sepchan)
    (when separator (set-ptr-field! st 24 0 separator))
    (bytevector-u64-native-set! (nc-struct-bv st) 32 flags)
    st))

(define* (make-ncplot-options #:key (maxchannels 0) (minchannels 0)
                              (legendstyle 0) (gridtype 0) (rangex 0)
                              (title #f) (flags 0))
  (let ((st (alloc-struct 'ncplot_options 48 1)))
    (bytevector-u64-native-set! (nc-struct-bv st) 0 maxchannels)
    (bytevector-u64-native-set! (nc-struct-bv st) 8 minchannels)
    (bytevector-u16-native-set! (nc-struct-bv st) 16 legendstyle)
    (bytevector-s32-native-set! (nc-struct-bv st) 20 gridtype)
    (bytevector-s32-native-set! (nc-struct-bv st) 24 rangex)
    (when title (set-ptr-field! st 32 0 title))
    (bytevector-u64-native-set! (nc-struct-bv st) 40 flags)
    st))

(define* (make-ncreel-options #:key (bordermask 0) (borderchan 0)
                              (tabletmask 0) (tabletchan 0)
                              (focusedchan 0) (flags 0))
  (let ((st (alloc-struct 'ncreel_options 48 0)))
    (bytevector-u32-native-set! (nc-struct-bv st) 0 bordermask)
    (bytevector-u64-native-set! (nc-struct-bv st) 8 borderchan)
    (bytevector-u32-native-set! (nc-struct-bv st) 16 tabletmask)
    (bytevector-u64-native-set! (nc-struct-bv st) 24 tabletchan)
    (bytevector-u64-native-set! (nc-struct-bv st) 32 focusedchan)
    (bytevector-u64-native-set! (nc-struct-bv st) 40 flags)
    st))

(define* (make-ncfdplane-options #:key (curry #f) (follow? #f) (flags 0))
  (let ((st (alloc-struct 'ncfdplane_options 24 1)))
    (when curry (set-ptr-field! st 0 0 curry))
    (bytevector-u8-set! (nc-struct-bv st) 8 (if follow? 1 0))
    (bytevector-u64-native-set! (nc-struct-bv st) 16 flags)
    st))

(define* (make-ncsubproc-options #:key (curry #f) (restart-period 0) (flags 0))
  (let ((st (alloc-struct 'ncsubproc_options 24 1)))
    (when curry (set-ptr-field! st 0 0 curry))
    (bytevector-u64-native-set! (nc-struct-bv st) 8 restart-period)
    (bytevector-u64-native-set! (nc-struct-bv st) 16 flags)
    st))
