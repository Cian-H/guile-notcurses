;;; notcurses/channel.scm — 32-bit channel and 64-bit channel-pair manipulation.

(define-module (notcurses channel)
  #:use-module (system foreign)
  #:use-module (notcurses ffi)
  #:export (ncchannel_alpha
            ncchannel_b
            ncchannel_default_p
            ncchannel_g
            ncchannel_palindex
            ncchannel_palindex_p
            ncchannel_r
            ncchannel_rgb
            ncchannel_rgb8
            ncchannel_rgb_p
            ncchannel_set
            ncchannel_set_alpha
            ncchannel_set_default
            ncchannel_set_palindex
            ncchannel_set_rgb8
            ncchannel_set_rgb8_clipped
            ncchannels_bchannel
            ncchannels_bg_alpha
            ncchannels_bg_default_p
            ncchannels_bg_palindex
            ncchannels_bg_palindex_p
            ncchannels_bg_rgb
            ncchannels_bg_rgb8
            ncchannels_bg_rgb_p
            ncchannels_channels
            ncchannels_combine
            ncchannels_fchannel
            ncchannels_fg_alpha
            ncchannels_fg_default_p
            ncchannels_fg_palindex
            ncchannels_fg_palindex_p
            ncchannels_fg_rgb
            ncchannels_fg_rgb8
            ncchannels_fg_rgb_p
            ncchannels_reverse
            ncchannels_set_bchannel
            ncchannels_set_bg_alpha
            ncchannels_set_bg_default
            ncchannels_set_bg_palindex
            ncchannels_set_bg_rgb
            ncchannels_set_bg_rgb8
            ncchannels_set_bg_rgb8_clipped
            ncchannels_set_channels
            ncchannels_set_fchannel
            ncchannels_set_fg_alpha
            ncchannels_set_fg_default
            ncchannels_set_fg_palindex
            ncchannels_set_fg_rgb
            ncchannels_set_fg_rgb8
            ncchannels_set_fg_rgb8_clipped))

(define-nc ncchannel_alpha "ncchannel_alpha" uint32 (uint32))
(define-nc ncchannel_b "ncchannel_b" unsigned-int (uint32))
(define-nc ncchannel_default_p "ncchannel_default_p" bool (uint32))
(define-nc ncchannel_g "ncchannel_g" unsigned-int (uint32))
(define-nc ncchannel_palindex "ncchannel_palindex" unsigned-int (uint32))
(define-nc ncchannel_palindex_p "ncchannel_palindex_p" bool (uint32))
(define-nc ncchannel_r "ncchannel_r" unsigned-int (uint32))
(define-nc ncchannel_rgb "ncchannel_rgb" uint32 (uint32))
(define-nc ncchannel_rgb8 "ncchannel_rgb8" uint32 (uint32 * * *))
(define-nc ncchannel_rgb_p "ncchannel_rgb_p" bool (uint32))
(define-nc ncchannel_set "ncchannel_set" int (* uint32))
(define-nc ncchannel_set_alpha "ncchannel_set_alpha" int (* unsigned-int))
(define-nc ncchannel_set_default "ncchannel_set_default" uint32 (*))
(define-nc ncchannel_set_palindex "ncchannel_set_palindex" int (* unsigned-int))
(define-nc ncchannel_set_rgb8 "ncchannel_set_rgb8" int (* unsigned-int unsigned-int unsigned-int))
(define-nc ncchannel_set_rgb8_clipped "ncchannel_set_rgb8_clipped" void (* int int int))
(define-nc ncchannels_bchannel "ncchannels_bchannel" uint32 (uint64))
(define-nc ncchannels_bg_alpha "ncchannels_bg_alpha" unsigned-int (uint64))
(define-nc ncchannels_bg_default_p "ncchannels_bg_default_p" bool (uint64))
(define-nc ncchannels_bg_palindex "ncchannels_bg_palindex" unsigned-int (uint64))
(define-nc ncchannels_bg_palindex_p "ncchannels_bg_palindex_p" bool (uint64))
(define-nc ncchannels_bg_rgb "ncchannels_bg_rgb" uint32 (uint64))
(define-nc ncchannels_bg_rgb8 "ncchannels_bg_rgb8" uint32 (uint64 * * *))
(define-nc ncchannels_bg_rgb_p "ncchannels_bg_rgb_p" bool (uint64))
(define-nc ncchannels_channels "ncchannels_channels" uint64 (uint64))
(define-nc ncchannels_combine "ncchannels_combine" uint64 (uint32 uint32))
(define-nc ncchannels_fchannel "ncchannels_fchannel" uint32 (uint64))
(define-nc ncchannels_fg_alpha "ncchannels_fg_alpha" unsigned-int (uint64))
(define-nc ncchannels_fg_default_p "ncchannels_fg_default_p" bool (uint64))
(define-nc ncchannels_fg_palindex "ncchannels_fg_palindex" unsigned-int (uint64))
(define-nc ncchannels_fg_palindex_p "ncchannels_fg_palindex_p" bool (uint64))
(define-nc ncchannels_fg_rgb "ncchannels_fg_rgb" uint32 (uint64))
(define-nc ncchannels_fg_rgb8 "ncchannels_fg_rgb8" uint32 (uint64 * * *))
(define-nc ncchannels_fg_rgb_p "ncchannels_fg_rgb_p" bool (uint64))
(define-nc ncchannels_reverse "ncchannels_reverse" uint64 (uint64))
(define-nc ncchannels_set_bchannel "ncchannels_set_bchannel" uint64 (* uint32))
(define-nc ncchannels_set_bg_alpha "ncchannels_set_bg_alpha" int (* unsigned-int))
(define-nc ncchannels_set_bg_default "ncchannels_set_bg_default" uint64 (*))
(define-nc ncchannels_set_bg_palindex "ncchannels_set_bg_palindex" int (* unsigned-int))
(define-nc ncchannels_set_bg_rgb "ncchannels_set_bg_rgb" int (* unsigned-int))
(define-nc ncchannels_set_bg_rgb8 "ncchannels_set_bg_rgb8" int (* unsigned-int unsigned-int unsigned-int))
(define-nc ncchannels_set_bg_rgb8_clipped "ncchannels_set_bg_rgb8_clipped" void (* int int int))
(define-nc ncchannels_set_channels "ncchannels_set_channels" uint64 (* uint64))
(define-nc ncchannels_set_fchannel "ncchannels_set_fchannel" uint64 (* uint32))
(define-nc ncchannels_set_fg_alpha "ncchannels_set_fg_alpha" int (* unsigned-int))
(define-nc ncchannels_set_fg_default "ncchannels_set_fg_default" uint64 (*))
(define-nc ncchannels_set_fg_palindex "ncchannels_set_fg_palindex" int (* unsigned-int))
(define-nc ncchannels_set_fg_rgb "ncchannels_set_fg_rgb" int (* unsigned-int))
(define-nc ncchannels_set_fg_rgb8 "ncchannels_set_fg_rgb8" int (* unsigned-int unsigned-int unsigned-int))
(define-nc ncchannels_set_fg_rgb8_clipped "ncchannels_set_fg_rgb8_clipped" void (* int int int))
