;;; notcurses/input.scm — Input reading, ncinput predicates, nckey helpers, and mouse/signal control.

(define-module (notcurses input)
  #:use-module (system foreign)
  #:use-module (notcurses ffi)
  #:export (ncinput_alt_p
            ncinput_capslock_p
            ncinput_ctrl_p
            ncinput_equal_p
            ncinput_hyper_p
            ncinput_meta_p
            ncinput_nomod_p
            ncinput_numlock_p
            ncinput_shift_p
            ncinput_super_p
            nckey_mouse_p
            nckey_pua_p
            nckey_supppuaa_p
            nckey_supppuab_p
            nckey_synthesized_p
            notcurses_get
            notcurses_get_blocking
            notcurses_get_nblock
            notcurses_getvec
            notcurses_inputready_fd
            notcurses_linesigs_disable
            notcurses_linesigs_enable
            notcurses_mice_disable
            notcurses_mice_enable))

(define-nc ncinput_alt_p "ncinput_alt_p" bool (*))
(define-nc ncinput_capslock_p "ncinput_capslock_p" bool (*))
(define-nc ncinput_ctrl_p "ncinput_ctrl_p" bool (*))
(define-nc ncinput_equal_p "ncinput_equal_p" bool (* *))
(define-nc ncinput_hyper_p "ncinput_hyper_p" bool (*))
(define-nc ncinput_meta_p "ncinput_meta_p" bool (*))
(define-nc ncinput_nomod_p "ncinput_nomod_p" bool (*))
(define-nc ncinput_numlock_p "ncinput_numlock_p" bool (*))
(define-nc ncinput_shift_p "ncinput_shift_p" bool (*))
(define-nc ncinput_super_p "ncinput_super_p" bool (*))
(define-nc nckey_mouse_p "nckey_mouse_p" bool (uint32))
(define-nc nckey_pua_p "nckey_pua_p" bool (uint32))
(define-nc nckey_supppuaa_p "nckey_supppuaa_p" bool (uint32))
(define-nc nckey_supppuab_p "nckey_supppuab_p" bool (uint32))
(define-nc nckey_synthesized_p "nckey_synthesized_p" bool (uint32))
(define-nc notcurses_get "notcurses_get" uint32 (* * *))
(define-nc notcurses_get_blocking "notcurses_get_blocking" uint32 (* *))
(define-nc notcurses_get_nblock "notcurses_get_nblock" uint32 (* *))
(define-nc notcurses_getvec "notcurses_getvec" int (* * * int))
(define-nc notcurses_inputready_fd "notcurses_inputready_fd" int (*))
(define-nc notcurses_linesigs_disable "notcurses_linesigs_disable" int (*))
(define-nc notcurses_linesigs_enable "notcurses_linesigs_enable" int (*))
(define-nc notcurses_mice_disable "notcurses_mice_disable" int (*))
(define-nc notcurses_mice_enable "notcurses_mice_enable" int (* unsigned-int))
