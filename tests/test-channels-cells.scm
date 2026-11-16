;;; tests/test-channels-cells.scm — Headless tests for channels, cells, input, metrics, and visuals.

(use-modules (srfi srfi-64)
             (rnrs bytevectors)
             (system foreign)
             (notcurses))

(test-begin "channels-cells")

(test-assert "ncchannels fg/bg rgb8 and alpha roundtrip"
  (let* ((bv (make-bytevector 8 0))
         (r (make-bytevector 4 0))
         (g (make-bytevector 4 0))
         (b (make-bytevector 4 0))
         (p (bytevector->pointer bv)))
    (ncchannels_set_fg_rgb8 p #x12 #x34 #x56)
    (ncchannels_set_bg_rgb8 p #xaa #xbb #xcc)
    (ncchannels_set_bg_alpha p NCALPHA_BLEND)
    (let* ((chans (bytevector-u64-native-ref bv 0))
           (fg-chan (ncchannels_fg_rgb8 chans (bytevector->pointer r) (bytevector->pointer g) (bytevector->pointer b)))
           (fg (ncchannels_fg_rgb chans))
           (rf (bytevector-u32-native-ref r 0))
           (gf (bytevector-u32-native-ref g 0))
           (bf (bytevector-u32-native-ref b 0)))
      (and (= (logand fg-chan #xffffff) #x123456)
           (= (ncchannels_fg_alpha chans) NCALPHA_OPAQUE)
           (= fg #x123456)
           (= rf #x12) (= gf #x34) (= bf #x56)
           (= (ncchannels_bg_alpha chans) NCALPHA_BLEND)
           (not (ncchannels_fg_default_p chans))
           (ncchannels_fg_rgb_p chans)))))

(test-assert "ncpixel pack and unpack"
  (let ((px (ncpixel #x11 #x22 #x33)))
    (and (= (ncpixel_r px) #x11)
         (= (ncpixel_g px) #x22)
         (= (ncpixel_b px) #x33)
         (= (ncpixel_a px) #xff))))

(test-assert "nccell init, styles, and colors"
  (let* ((cell (make-nccell))
         (p (nc-struct-ptr cell)))
    (nccell_init p)
    (nccell_set_fg_rgb8 p #x10 #x20 #x30)
    (nccell_on_styles p NCSTYLE_BOLD)
    (let ((bold-on? (= (logand (nccell_styles p) NCSTYLE_BOLD) NCSTYLE_BOLD))
          (fg-default? (nccell_fg_default_p p))
          (bg-default? (nccell_bg_default_p p)))
      (nccell_off_styles p NCSTYLE_BOLD)
      (and bold-on?
           (not fg-default?)
           bg-default?
           (= (nccell_styles p) 0)))))

(test-assert "ncinput predicates and nckey helpers"
  (let ((ni1 (make-ncinput))
        (ni2 (make-ncinput)))
    (ncinput-set-id! ni1 (char->integer #\a))
    (ncinput-set-modifiers! ni1 NCKEY_MOD_CTRL)
    (ncinput-copy! ni2 ni1)
    (and (ncinput_ctrl_p (nc-struct-ptr ni1))
         (not (ncinput_alt_p (nc-struct-ptr ni1)))
         (not (ncinput_nomod_p (nc-struct-ptr ni1)))
         (ncinput_equal_p (nc-struct-ptr ni1) (nc-struct-ptr ni2))
         (nckey_synthesized_p NCKEY_ENTER)
         (not (nckey_synthesized_p (char->integer #\a)))
         (nckey_mouse_p NCKEY_BUTTON1)
         (not (nckey_mouse_p NCKEY_ENTER)))))

(test-assert "ncstrwidth and ncbprefix"
  (let ((buf (make-bytevector 32 0)))
    (ncbprefix 1024 1 (bytevector->pointer buf) 0)
    (and (= 5 (ncstrwidth (string->pointer "hello") %null-pointer %null-pointer))
         (> (string-length (c-string->scheme (bytevector->pointer buf))) 0))))

(test-assert "ncvisual_from_rgba and ncvisual_destroy"
  (let* ((rgba (make-bytevector (* 4 4 4) #xff))
         (v (ncvisual_from_rgba (bytevector->pointer rgba) 4 16 4)))
    (and (not (null-pointer? v))
         (begin
           (ncvisual_destroy v)
           #t))))

(test-end "channels-cells")
