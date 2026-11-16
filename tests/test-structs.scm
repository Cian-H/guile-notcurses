;;; tests/test-structs.scm — Verify C struct sizes, offsets, and accessors.

(use-modules (srfi srfi-64)
             (rnrs bytevectors)
             (system foreign)
             (notcurses))

(test-begin "structs")

(test-equal "sizeof(notcurses_options)" 40 (bytevector-length (nc-struct-bv (make-notcurses-options))))
(test-equal "sizeof(ncplane_options)" 56 (bytevector-length (nc-struct-bv (make-ncplane-options))))
(test-equal "sizeof(nccell)" 16 (bytevector-length (nc-struct-bv (make-nccell))))
(test-equal "sizeof(ncinput)" 52 (bytevector-length (nc-struct-bv (make-ncinput))))
(test-equal "sizeof(ncvisual_options)" 64 (bytevector-length (nc-struct-bv (make-ncvisual-options))))
(test-equal "sizeof(ncvgeom)" 68 (bytevector-length (nc-struct-bv (make-ncvgeom))))
(test-equal "sizeof(nccapabilities)" 12 (bytevector-length (nc-struct-bv (make-nccapabilities))))
(test-equal "sizeof(ncpalette)" 1024 (bytevector-length (nc-struct-bv (make-ncpalette))))
(test-equal "sizeof(ncstats)" 288 (bytevector-length (nc-struct-bv (make-ncstats))))
(test-equal "sizeof(ncmenu_item)" 64 (bytevector-length (nc-struct-bv (make-ncmenu-item))))
(test-equal "sizeof(ncmenu_section)" 80 (bytevector-length (nc-struct-bv (make-ncmenu-section))))
(test-equal "sizeof(ncmenu_options)" 40 (bytevector-length (nc-struct-bv (make-ncmenu-options))))
(test-equal "sizeof(ncselector_item)" 16 (bytevector-length (nc-struct-bv (make-ncselector-item))))
(test-equal "sizeof(ncselector_options)" 88 (bytevector-length (nc-struct-bv (make-ncselector-options))))
(test-equal "sizeof(ncmselector_item)" 24 (bytevector-length (nc-struct-bv (make-ncmselector-item))))
(test-equal "sizeof(ncmultiselector_options)" 88 (bytevector-length (nc-struct-bv (make-ncmultiselector-options))))
(test-equal "sizeof(ncreader_options)" 24 (bytevector-length (nc-struct-bv (make-ncreader-options))))
(test-equal "sizeof(nctree_item)" 24 (bytevector-length (nc-struct-bv (make-nctree-item))))
(test-equal "sizeof(nctree_options)" 40 (bytevector-length (nc-struct-bv (make-nctree-options))))
(test-equal "sizeof(ncprogbar_options)" 24 (bytevector-length (nc-struct-bv (make-ncprogbar-options))))
(test-equal "sizeof(nctabbed_options)" 40 (bytevector-length (nc-struct-bv (make-nctabbed-options))))
(test-equal "sizeof(ncplot_options)" 48 (bytevector-length (nc-struct-bv (make-ncplot-options))))
(test-equal "sizeof(ncreel_options)" 48 (bytevector-length (nc-struct-bv (make-ncreel-options))))
(test-equal "sizeof(ncfdplane_options)" 24 (bytevector-length (nc-struct-bv (make-ncfdplane-options))))
(test-equal "sizeof(ncsubproc_options)" 24 (bytevector-length (nc-struct-bv (make-ncsubproc-options))))

(test-assert "notcurses_options roundtrip"
  (let ((opts (make-notcurses-options #:termtype "xterm-256color"
                                      #:loglevel NCLOGLEVEL_WARNING
                                      #:margin-t 1 #:margin-r 2
                                      #:margin-b 3 #:margin-l 4
                                      #:flags NCOPTION_SUPPRESS_BANNERS)))
    (and (equal? "xterm-256color" (notcurses-options-termtype opts))
         (= NCLOGLEVEL_WARNING (notcurses-options-loglevel opts))
         (= 1 (notcurses-options-margin-t opts))
         (= 2 (notcurses-options-margin-r opts))
         (= 3 (notcurses-options-margin-b opts))
         (= 4 (notcurses-options-margin-l opts))
         (= NCOPTION_SUPPRESS_BANNERS (notcurses-options-flags opts)))))

(test-assert "ncplane_options roundtrip"
  (let ((opts (make-ncplane-options #:y -2 #:x 5 #:rows 20 #:cols 40
                                    #:name "status"
                                    #:flags NCPLANE_OPTION_HORALIGNED)))
    (and (= -2 (ncplane-options-y opts))
         (= 5 (ncplane-options-x opts))
         (= 20 (ncplane-options-rows opts))
         (= 40 (ncplane-options-cols opts))
         (equal? "status" (ncplane-options-name opts))
         (= NCPLANE_OPTION_HORALIGNED (ncplane-options-flags opts)))))

(test-assert "ncinput-copy! preserves fields"
  (let ((a (make-ncinput))
        (b (make-ncinput)))
    (ncinput-set-id! a NCKEY_ENTER)
    (ncinput-set-y! a 10)
    (ncinput-set-x! a 25)
    (ncinput-set-evtype! a NCTYPE_PRESS)
    (ncinput-set-modifiers! a NCKEY_MOD_CTRL)
    (ncinput-copy! b a)
    (and (= (ncinput-id b) NCKEY_ENTER)
         (= (ncinput-y b) 10)
         (= (ncinput-x b) 25)
         (= (ncinput-evtype b) NCTYPE_PRESS)
         (= (ncinput-modifiers b) NCKEY_MOD_CTRL))))

(test-assert "->pointer handles struct, bytevector, pointer, and #f"
  (let ((c (make-nccell))
        (bv (make-bytevector 4 0)))
    (and (pointer? (->pointer c))
         (pointer? (->pointer bv))
         (null-pointer? (->pointer #f)))))

(test-end "structs")
