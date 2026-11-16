;;; notcurses/cell.scm — nccell and box-drawing cell initialization and styling.

(define-module (notcurses cell)
  #:use-module (system foreign)
  #:use-module (notcurses ffi)
  #:export (nccell_bchannel
            nccell_bg_alpha
            nccell_bg_default_p
            nccell_bg_palindex
            nccell_bg_palindex_p
            nccell_bg_rgb
            nccell_bg_rgb8
            nccell_channels
            nccell_cols
            nccell_double_wide_p
            nccell_duplicate
            nccell_extended_gcluster
            nccell_extract
            nccell_fchannel
            nccell_fg_alpha
            nccell_fg_default_p
            nccell_fg_palindex
            nccell_fg_palindex_p
            nccell_fg_rgb
            nccell_fg_rgb8
            nccell_init
            nccell_load
            nccell_load_char
            nccell_load_egc32
            nccell_load_ucs32
            nccell_off_styles
            nccell_on_styles
            nccell_prime
            nccell_release
            nccell_set_bchannel
            nccell_set_bg_alpha
            nccell_set_bg_default
            nccell_set_bg_palindex
            nccell_set_bg_rgb
            nccell_set_bg_rgb8
            nccell_set_bg_rgb8_clipped
            nccell_set_channels
            nccell_set_fchannel
            nccell_set_fg_alpha
            nccell_set_fg_default
            nccell_set_fg_palindex
            nccell_set_fg_rgb
            nccell_set_fg_rgb8
            nccell_set_fg_rgb8_clipped
            nccell_set_styles
            nccell_strdup
            nccell_styles
            nccell_wide_left_p
            nccell_wide_right_p
            nccells_ascii_box
            nccells_double_box
            nccells_heavy_box
            nccells_light_box
            nccells_load_box
            nccells_rounded_box))

(define-nc nccell_bchannel "nccell_bchannel" uint32 (*))
(define-nc nccell_bg_alpha "nccell_bg_alpha" uint32 (*))
(define-nc nccell_bg_default_p "nccell_bg_default_p" bool (*))
(define-nc nccell_bg_palindex "nccell_bg_palindex" uint32 (*))
(define-nc nccell_bg_palindex_p "nccell_bg_palindex_p" bool (*))
(define-nc nccell_bg_rgb "nccell_bg_rgb" uint32 (*))
(define-nc nccell_bg_rgb8 "nccell_bg_rgb8" uint32 (* * * *))
(define-nc nccell_channels "nccell_channels" uint64 (*))
(define-nc nccell_cols "nccell_cols" unsigned-int (*))
(define-nc nccell_double_wide_p "nccell_double_wide_p" bool (*))
(define-nc nccell_duplicate "nccell_duplicate" int (* * *))
(define-nc nccell_extended_gcluster "nccell_extended_gcluster" * (* *))
(define-nc nccell_extract "nccell_extract" * (* * * *))
(define-nc nccell_fchannel "nccell_fchannel" uint32 (*))
(define-nc nccell_fg_alpha "nccell_fg_alpha" uint32 (*))
(define-nc nccell_fg_default_p "nccell_fg_default_p" bool (*))
(define-nc nccell_fg_palindex "nccell_fg_palindex" uint32 (*))
(define-nc nccell_fg_palindex_p "nccell_fg_palindex_p" bool (*))
(define-nc nccell_fg_rgb "nccell_fg_rgb" uint32 (*))
(define-nc nccell_fg_rgb8 "nccell_fg_rgb8" uint32 (* * * *))
(define-nc nccell_init "nccell_init" void (*))
(define-nc nccell_load "nccell_load" int (* * *))
(define-nc nccell_load_char "nccell_load_char" int (* * int8))
(define-nc nccell_load_egc32 "nccell_load_egc32" int (* * uint32))
(define-nc nccell_load_ucs32 "nccell_load_ucs32" int (* * uint32))
(define-nc nccell_off_styles "nccell_off_styles" void (* unsigned-int))
(define-nc nccell_on_styles "nccell_on_styles" void (* unsigned-int))
(define-nc nccell_prime "nccell_prime" int (* * * uint16 uint64))
(define-nc nccell_release "nccell_release" void (* *))
(define-nc nccell_set_bchannel "nccell_set_bchannel" uint64 (* uint32))
(define-nc nccell_set_bg_alpha "nccell_set_bg_alpha" int (* unsigned-int))
(define-nc nccell_set_bg_default "nccell_set_bg_default" void (*))
(define-nc nccell_set_bg_palindex "nccell_set_bg_palindex" int (* unsigned-int))
(define-nc nccell_set_bg_rgb "nccell_set_bg_rgb" int (* uint32))
(define-nc nccell_set_bg_rgb8 "nccell_set_bg_rgb8" int (* unsigned-int unsigned-int unsigned-int))
(define-nc nccell_set_bg_rgb8_clipped "nccell_set_bg_rgb8_clipped" void (* int int int))
(define-nc nccell_set_channels "nccell_set_channels" uint64 (* uint64))
(define-nc nccell_set_fchannel "nccell_set_fchannel" uint64 (* uint32))
(define-nc nccell_set_fg_alpha "nccell_set_fg_alpha" int (* unsigned-int))
(define-nc nccell_set_fg_default "nccell_set_fg_default" void (*))
(define-nc nccell_set_fg_palindex "nccell_set_fg_palindex" int (* unsigned-int))
(define-nc nccell_set_fg_rgb "nccell_set_fg_rgb" int (* uint32))
(define-nc nccell_set_fg_rgb8 "nccell_set_fg_rgb8" int (* unsigned-int unsigned-int unsigned-int))
(define-nc nccell_set_fg_rgb8_clipped "nccell_set_fg_rgb8_clipped" void (* int int int))
(define-nc nccell_set_styles "nccell_set_styles" void (* unsigned-int))
(define-nc nccell_strdup "nccell_strdup" * (* *))
(define-nc nccell_styles "nccell_styles" uint16 (*))
(define-nc nccell_wide_left_p "nccell_wide_left_p" bool (*))
(define-nc nccell_wide_right_p "nccell_wide_right_p" bool (*))
(define-nc nccells_ascii_box "nccells_ascii_box" int (* uint16 uint64 * * * * * *))
(define-nc nccells_double_box "nccells_double_box" int (* uint16 uint64 * * * * * *))
(define-nc nccells_heavy_box "nccells_heavy_box" int (* uint16 uint64 * * * * * *))
(define-nc nccells_light_box "nccells_light_box" int (* uint16 uint64 * * * * * *))
(define-nc nccells_load_box "nccells_load_box" int (* uint16 uint64 * * * * * * *))
(define-nc nccells_rounded_box "nccells_rounded_box" int (* uint16 uint64 * * * * * *))
