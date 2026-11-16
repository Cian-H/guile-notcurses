;;; tests/test-live-pty.scm — Live PTY integration tests for (notcurses) and (notcurses compat curses).
;;;
;;; Mirrors libnotcurses-sys and nim-notcurses live session tests: exercises
;;; notcurses_init, ncplane, nccell_load, box drawing, ncvisual_blit, stats,
;;; capabilities, palette, widgets, ncdirect, and compat/curses under a real PTY.

(use-modules (srfi srfi-64)
             (rnrs bytevectors)
             (system foreign)
             (notcurses)
             ((notcurses compat curses) #:prefix curses:))

(test-begin "live-pty")

(test-assert "notcurses_init, planes, cells, visuals, stats, widgets, stop"
  (let* ((opts (make-notcurses-options
                #:flags (logior NCOPTION_NO_ALTERNATE_SCREEN
                                NCOPTION_SUPPRESS_BANNERS
                                NCOPTION_DRAIN_INPUT)))
         (nc (notcurses_init (nc-struct-ptr opts) %null-pointer)))
    (and (not (null-pointer? nc))
         (let* ((std (notcurses_stdplane nc))
                (rows-bv (make-bytevector 4 0))
                (cols-bv (make-bytevector 4 0)))
           (ncplane_dim_yx std (bytevector->pointer rows-bv) (bytevector->pointer cols-bv))
           (let* ((rows (bytevector-u32-native-ref rows-bv 0))
                  (cols (bytevector-u32-native-ref cols-bv 0))
                  ;; Create child plane
                  (popts (make-ncplane-options #:y 1 #:x 1 #:rows 10 #:cols 30 #:name "child"))
                  (child (ncplane_create std (nc-struct-ptr popts)))
                  ;; Text output & printf
                  (put-ok (>= (ncplane_putstr_yx child 0 0 (string->pointer "hello")) 0))
                  (printf-ok (>= (ncplane_printf_yx child 1 0 "val=~a" 42) 0))
                  ;; Cell load & prime (mirroring libnotcurses-sys cell tests)
                  (cell (make-nccell))
                  (cp (nc-struct-ptr cell))
                  (b1 (nccell_load child cp (string->pointer "e")))
                  (b2 (nccell_load child cp (string->pointer "é")))
                  (b4 (nccell_load child cp (string->pointer "🚀")))
                  ;; Box drawing
                  (ul (make-nccell)) (ur (make-nccell))
                  (ll (make-nccell)) (lr (make-nccell))
                  (hl (make-nccell)) (vl (make-nccell))
                  (box-prep (= 0 (nccells_light_box child 0 0
                                                    (nc-struct-ptr ul) (nc-struct-ptr ur)
                                                    (nc-struct-ptr ll) (nc-struct-ptr lr)
                                                    (nc-struct-ptr hl) (nc-struct-ptr vl))))
                  (box-draw (= 0 (ncplane_box child
                                              (nc-struct-ptr ul) (nc-struct-ptr ur)
                                              (nc-struct-ptr ll) (nc-struct-ptr lr)
                                              (nc-struct-ptr hl) (nc-struct-ptr vl)
                                              5 10 0)))
                  ;; Visual blit onto plane
                  (rgba (make-bytevector (* 4 4 4) #x80))
                  (vis (ncvisual_from_rgba (bytevector->pointer rgba) 4 16 4))
                  (vopts (make-ncvisual-options #:n child #:y 2 #:x 2 #:blitter NCBLIT_1x1))
                  (blitted (ncvisual_blit nc vis (nc-struct-ptr vopts)))
                  ;; Palette & stats & capabilities
                  (pal (ncpalette_new nc))
                  (caps (notcurses_capabilities nc))
                  (stats (make-ncstats))
                  ;; Progbar widget
                  (pbar-plane (ncplane_create std (nc-struct-ptr (make-ncplane-options #:y 12 #:x 1 #:rows 1 #:cols 20))))
                  (pbar (ncprogbar_create pbar-plane (nc-struct-ptr (make-ncprogbar-options))))
                  (pbar-set (= 0 (ncprogbar_set_progress pbar 0.5)))
                  ;; Render & read contents
                  (rendered (= 0 (notcurses_render nc)))
                  (contents (c-string-free->scheme (ncplane_contents child 0 0 2 10))))
             (notcurses_stats nc (nc-struct-ptr stats))
             (let ((renders-ok (>= (ncstats-renders stats) 1)))
               (ncprogbar_destroy pbar)
               (ncvisual_destroy vis)
               (ncpalette_free pal)
               (nccell_release child cp)
               (nccell_release child (nc-struct-ptr ul))
               (nccell_release child (nc-struct-ptr ur))
               (nccell_release child (nc-struct-ptr ll))
               (nccell_release child (nc-struct-ptr lr))
               (nccell_release child (nc-struct-ptr hl))
               (nccell_release child (nc-struct-ptr vl))
               (ncplane_destroy child)
               (let ((stopped (= 0 (notcurses_stop nc))))
                 (and (> rows 0) (> cols 0)
                      (not (null-pointer? child))
                      put-ok printf-ok
                      (= b1 1) (= b2 2) (= b4 4)
                      box-prep box-draw
                      (not (null-pointer? blitted))
                      (not (null-pointer? pal))
                      (not (null-pointer? caps))
                      pbar-set rendered renders-ok
                      (string? contents)
                      stopped))))))))

(test-assert "ncdirect_init, output, and ncdirect_stop"
  (let ((ncd (ncdirect_init %null-pointer %null-pointer
                            (logior NCDIRECT_OPTION_DRAIN_INPUT
                                    NCDIRECT_OPTION_NO_QUIT_SIGHANDLERS))))
    (and (not (null-pointer? ncd))
         (let ((cols (ncdirect_dim_x ncd))
               (rows (ncdirect_dim_y ncd))
               (put-ok (>= (ncdirect_putstr ncd 0 (string->pointer "direct-ok\n")) 0))
               (stop-ok (= 0 (ncdirect_stop ncd))))
           (and (> cols 0) (> rows 0) put-ok stop-ok)))))

(test-assert "compat/curses initscr, draw, refresh, endwin"
  (let ((win (curses:initscr)))
    (and (not (null-pointer? win))
         (let ((my (curses:getmaxy win))
               (mx (curses:getmaxx win)))
           (curses:init-pair! 1 curses:COLOR_GREEN curses:COLOR_BLACK)
           (curses:attr-on! win (curses:color-pair 1))
           (curses:attr-on! win curses:A_BOLD)
           (curses:move win 0 0)
           (curses:addstr win "curses-compat-ok")
           (curses:attr-off! win curses:A_BOLD)
           (curses:attr-off! win (curses:color-pair 1))
           (let ((r (curses:refresh win)))
             (curses:erase win)
             (curses:endwin)
             (and (> my 0) (> mx 0) (= r 0)))))))

(test-end "live-pty")
