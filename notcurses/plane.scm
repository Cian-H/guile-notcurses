;;; notcurses/plane.scm — ncplane creation, geometry, text output, scrolling, and drawing.

(define-module (notcurses plane)
  #:use-module (system foreign)
  #:use-module (notcurses ffi)
  #:export (ncplane_above
            ncplane_abs_x
            ncplane_abs_y
            ncplane_abs_yx
            ncplane_as_rgba
            ncplane_ascii_box
            ncplane_at_cursor
            ncplane_at_cursor_cell
            ncplane_at_yx
            ncplane_at_yx_cell
            ncplane_autogrow_p
            ncplane_base
            ncplane_bchannel
            ncplane_below
            ncplane_bg_alpha
            ncplane_bg_default_p
            ncplane_bg_rgb
            ncplane_bg_rgb8
            ncplane_box
            ncplane_box_sized
            ncplane_center_abs
            ncplane_channels
            ncplane_contents
            ncplane_create
            ncplane_cursor_move_rel
            ncplane_cursor_move_yx
            ncplane_cursor_x
            ncplane_cursor_y
            ncplane_cursor_yx
            ncplane_descendant_p
            ncplane_destroy
            ncplane_dim_x
            ncplane_dim_y
            ncplane_dim_yx
            ncplane_double_box
            ncplane_double_box_sized
            ncplane_dup
            ncplane_erase
            ncplane_erase_region
            ncplane_fadein
            ncplane_fadein_iteration
            ncplane_fadeout
            ncplane_fadeout_iteration
            ncplane_family_destroy
            ncplane_fchannel
            ncplane_fg_alpha
            ncplane_fg_default_p
            ncplane_fg_rgb
            ncplane_fg_rgb8
            ncplane_format
            ncplane_gradient
            ncplane_gradient2x1
            ncplane_greyscale
            ncplane_halign
            ncplane_hline
            ncplane_hline_interp
            ncplane_home
            ncplane_mergedown
            ncplane_mergedown_simple
            ncplane_move_above
            ncplane_move_below
            ncplane_move_bottom
            ncplane_move_family_above
            ncplane_move_family_below
            ncplane_move_family_bottom
            ncplane_move_family_top
            ncplane_move_rel
            ncplane_move_top
            ncplane_move_yx
            ncplane_name
            ncplane_notcurses
            ncplane_notcurses_const
            ncplane_off_styles
            ncplane_on_styles
            ncplane_parent
            ncplane_parent_const
            ncplane_perimeter
            ncplane_perimeter_double
            ncplane_perimeter_rounded
            ncplane_pixel_geom
            ncplane_polyfill_yx
            ncplane_pulse
            ncplane_putc
            ncplane_putc_yx
            ncplane_putchar
            ncplane_putchar_stained
            ncplane_putchar_yx
            ncplane_putegc
            ncplane_putegc_stained
            ncplane_putegc_yx
            ncplane_putnstr
            ncplane_putnstr_aligned
            ncplane_putnstr_yx
            ncplane_putstr
            ncplane_putstr_aligned
            ncplane_putstr_stained
            ncplane_putstr_yx
            ncplane_puttext
            ncplane_pututf32_yx
            ncplane_putwc
            ncplane_putwc_stained
            ncplane_putwc_utf32
            ncplane_putwc_yx
            ncplane_putwegc
            ncplane_putwegc_stained
            ncplane_putwegc_yx
            ncplane_putwstr
            ncplane_putwstr_aligned
            ncplane_putwstr_stained
            ncplane_putwstr_yx
            ncplane_qrcode
            ncplane_reparent
            ncplane_reparent_family
            ncplane_resize
            ncplane_resize_marginalized
            ncplane_resize_maximize
            ncplane_resize_placewithin
            ncplane_resize_realign
            ncplane_resize_simple
            ncplane_resizecb
            ncplane_rotate_ccw
            ncplane_rotate_cw
            ncplane_rounded_box
            ncplane_rounded_box_sized
            ncplane_scrolling_p
            ncplane_scrollup
            ncplane_scrollup_child
            ncplane_set_autogrow
            ncplane_set_base
            ncplane_set_base_cell
            ncplane_set_bchannel
            ncplane_set_bg_alpha
            ncplane_set_bg_default
            ncplane_set_bg_palindex
            ncplane_set_bg_rgb
            ncplane_set_bg_rgb8
            ncplane_set_bg_rgb8_clipped
            ncplane_set_channels
            ncplane_set_fchannel
            ncplane_set_fg_alpha
            ncplane_set_fg_default
            ncplane_set_fg_palindex
            ncplane_set_fg_rgb
            ncplane_set_fg_rgb8
            ncplane_set_fg_rgb8_clipped
            ncplane_set_name
            ncplane_set_resizecb
            ncplane_set_scrolling
            ncplane_set_styles
            ncplane_set_userptr
            ncplane_stain
            ncplane_styles
            ncplane_translate
            ncplane_translate_abs
            ncplane_userptr
            ncplane_valign
            ncplane_vline
            ncplane_vline_interp
            ncplane_vprintf
            ncplane_vprintf_aligned
            ncplane_vprintf_stained
            ncplane_vprintf_yx
            ncplane_x
            ncplane_y
            ncplane_yx
            ncplane_printf
            ncplane_printf_yx
            ncplane_printf_aligned
            ncplane_printf_stained))

(define-nc ncplane_above "ncplane_above" * (*))
(define-nc ncplane_abs_x "ncplane_abs_x" int (*))
(define-nc ncplane_abs_y "ncplane_abs_y" int (*))
(define-nc ncplane_abs_yx "ncplane_abs_yx" void (* * *))
(define-nc ncplane_as_rgba "ncplane_as_rgba" * (* int int int unsigned-int unsigned-int * *))
(define-nc ncplane_ascii_box "ncplane_ascii_box" int (* uint16 uint64 unsigned-int unsigned-int unsigned-int))
(define-nc ncplane_at_cursor "ncplane_at_cursor" * (* * *))
(define-nc ncplane_at_cursor_cell "ncplane_at_cursor_cell" int (* *))
(define-nc ncplane_at_yx "ncplane_at_yx" * (* int int * *))
(define-nc ncplane_at_yx_cell "ncplane_at_yx_cell" int (* int int *))
(define-nc ncplane_autogrow_p "ncplane_autogrow_p" bool (*))
(define-nc ncplane_base "ncplane_base" int (* *))
(define-nc ncplane_bchannel "ncplane_bchannel" uint32 (*))
(define-nc ncplane_below "ncplane_below" * (*))
(define-nc ncplane_bg_alpha "ncplane_bg_alpha" uint32 (*))
(define-nc ncplane_bg_default_p "ncplane_bg_default_p" bool (*))
(define-nc ncplane_bg_rgb "ncplane_bg_rgb" uint32 (*))
(define-nc ncplane_bg_rgb8 "ncplane_bg_rgb8" uint32 (* * * *))
(define-nc ncplane_box "ncplane_box" int (* * * * * * * unsigned-int unsigned-int unsigned-int))
(define-nc ncplane_box_sized "ncplane_box_sized" int (* * * * * * * unsigned-int unsigned-int unsigned-int))
(define-nc ncplane_center_abs "ncplane_center_abs" void (* * *))
(define-nc ncplane_channels "ncplane_channels" uint64 (*))
(define-nc ncplane_contents "ncplane_contents" * (* int int unsigned-int unsigned-int))
(define-nc ncplane_create "ncplane_create" * (* *))
(define-nc ncplane_cursor_move_rel "ncplane_cursor_move_rel" int (* int int))
(define-nc ncplane_cursor_move_yx "ncplane_cursor_move_yx" int (* int int))
(define-nc ncplane_cursor_x "ncplane_cursor_x" unsigned-int (*))
(define-nc ncplane_cursor_y "ncplane_cursor_y" unsigned-int (*))
(define-nc ncplane_cursor_yx "ncplane_cursor_yx" void (* * *))
(define-nc ncplane_descendant_p "ncplane_descendant_p" int (* *))
(define-nc ncplane_destroy "ncplane_destroy" int (*))
(define-nc ncplane_dim_x "ncplane_dim_x" unsigned-int (*))
(define-nc ncplane_dim_y "ncplane_dim_y" unsigned-int (*))
(define-nc ncplane_dim_yx "ncplane_dim_yx" void (* * *))
(define-nc ncplane_double_box "ncplane_double_box" int (* uint16 uint64 unsigned-int unsigned-int unsigned-int))
(define-nc ncplane_double_box_sized "ncplane_double_box_sized" int (* uint16 uint64 unsigned-int unsigned-int unsigned-int))
(define-nc ncplane_dup "ncplane_dup" * (* *))
(define-nc ncplane_erase "ncplane_erase" void (*))
(define-nc ncplane_erase_region "ncplane_erase_region" int (* int int int int))
(define-nc ncplane_fadein "ncplane_fadein" int (* * * *))
(define-nc ncplane_fadein_iteration "ncplane_fadein_iteration" int (* * int * *))
(define-nc ncplane_fadeout "ncplane_fadeout" int (* * * *))
(define-nc ncplane_fadeout_iteration "ncplane_fadeout_iteration" int (* * int * *))
(define-nc ncplane_family_destroy "ncplane_family_destroy" int (*))
(define-nc ncplane_fchannel "ncplane_fchannel" uint32 (*))
(define-nc ncplane_fg_alpha "ncplane_fg_alpha" uint32 (*))
(define-nc ncplane_fg_default_p "ncplane_fg_default_p" bool (*))
(define-nc ncplane_fg_rgb "ncplane_fg_rgb" uint32 (*))
(define-nc ncplane_fg_rgb8 "ncplane_fg_rgb8" uint32 (* * * *))
(define-nc ncplane_format "ncplane_format" int (* int int unsigned-int unsigned-int uint16))
(define-nc ncplane_gradient "ncplane_gradient" int (* int int unsigned-int unsigned-int * uint16 uint64 uint64 uint64 uint64))
(define-nc ncplane_gradient2x1 "ncplane_gradient2x1" int (* int int unsigned-int unsigned-int uint32 uint32 uint32 uint32))
(define-nc ncplane_greyscale "ncplane_greyscale" void (*))
(define-nc ncplane_halign "ncplane_halign" int (* int int))
(define-nc ncplane_hline "ncplane_hline" int (* * unsigned-int))
(define-nc ncplane_hline_interp "ncplane_hline_interp" int (* * unsigned-int uint64 uint64))
(define-nc ncplane_home "ncplane_home" void (*))
(define-nc ncplane_mergedown "ncplane_mergedown" int (* * int int unsigned-int unsigned-int int int))
(define-nc ncplane_mergedown_simple "ncplane_mergedown_simple" int (* *))
(define-nc ncplane_move_above "ncplane_move_above" int (* *))
(define-nc ncplane_move_below "ncplane_move_below" int (* *))
(define-nc ncplane_move_bottom "ncplane_move_bottom" void (*))
(define-nc ncplane_move_family_above "ncplane_move_family_above" int (* *))
(define-nc ncplane_move_family_below "ncplane_move_family_below" int (* *))
(define-nc ncplane_move_family_bottom "ncplane_move_family_bottom" void (*))
(define-nc ncplane_move_family_top "ncplane_move_family_top" void (*))
(define-nc ncplane_move_rel "ncplane_move_rel" int (* int int))
(define-nc ncplane_move_top "ncplane_move_top" void (*))
(define-nc ncplane_move_yx "ncplane_move_yx" int (* int int))
(define-nc ncplane_name "ncplane_name" * (*))
(define-nc ncplane_notcurses "ncplane_notcurses" * (*))
(define-nc ncplane_notcurses_const "ncplane_notcurses_const" * (*))
(define-nc ncplane_off_styles "ncplane_off_styles" void (* unsigned-int))
(define-nc ncplane_on_styles "ncplane_on_styles" void (* unsigned-int))
(define-nc ncplane_parent "ncplane_parent" * (*))
(define-nc ncplane_parent_const "ncplane_parent_const" * (*))
(define-nc ncplane_perimeter "ncplane_perimeter" int (* * * * * * * unsigned-int))
(define-nc ncplane_perimeter_double "ncplane_perimeter_double" int (* uint16 uint64 unsigned-int))
(define-nc ncplane_perimeter_rounded "ncplane_perimeter_rounded" int (* uint16 uint64 unsigned-int))
(define-nc ncplane_pixel_geom "ncplane_pixel_geom" void (* * * * * * *))
(define-nc ncplane_polyfill_yx "ncplane_polyfill_yx" int (* int int *))
(define-nc ncplane_pulse "ncplane_pulse" int (* * * *))
(define-nc ncplane_putc "ncplane_putc" int (* *))
(define-nc ncplane_putc_yx "ncplane_putc_yx" int (* int int *))
(define-nc ncplane_putchar "ncplane_putchar" int (* int8))
(define-nc ncplane_putchar_stained "ncplane_putchar_stained" int (* int8))
(define-nc ncplane_putchar_yx "ncplane_putchar_yx" int (* int int int8))
(define-nc ncplane_putegc "ncplane_putegc" int (* * *))
(define-nc ncplane_putegc_stained "ncplane_putegc_stained" int (* * *))
(define-nc ncplane_putegc_yx "ncplane_putegc_yx" int (* int int * *))
(define-nc ncplane_putnstr "ncplane_putnstr" int (* size_t *))
(define-nc ncplane_putnstr_aligned "ncplane_putnstr_aligned" int (* int int size_t *))
(define-nc ncplane_putnstr_yx "ncplane_putnstr_yx" int (* int int size_t *))
(define-nc ncplane_putstr "ncplane_putstr" int (* *))
(define-nc ncplane_putstr_aligned "ncplane_putstr_aligned" int (* int int *))
(define-nc ncplane_putstr_stained "ncplane_putstr_stained" int (* *))
(define-nc ncplane_putstr_yx "ncplane_putstr_yx" int (* int int *))
(define-nc ncplane_puttext "ncplane_puttext" int (* int int * *))
(define-nc ncplane_pututf32_yx "ncplane_pututf32_yx" int (* int int uint32))
(define-nc ncplane_putwc "ncplane_putwc" int (* int32))
(define-nc ncplane_putwc_stained "ncplane_putwc_stained" int (* int32))
(define-nc ncplane_putwc_utf32 "ncplane_putwc_utf32" int (* * *))
(define-nc ncplane_putwc_yx "ncplane_putwc_yx" int (* int int int32))
(define-nc ncplane_putwegc "ncplane_putwegc" int (* * *))
(define-nc ncplane_putwegc_stained "ncplane_putwegc_stained" int (* * *))
(define-nc ncplane_putwegc_yx "ncplane_putwegc_yx" int (* int int * *))
(define-nc ncplane_putwstr "ncplane_putwstr" int (* *))
(define-nc ncplane_putwstr_aligned "ncplane_putwstr_aligned" int (* int int *))
(define-nc ncplane_putwstr_stained "ncplane_putwstr_stained" int (* *))
(define-nc ncplane_putwstr_yx "ncplane_putwstr_yx" int (* int int *))
(define-nc ncplane_qrcode "ncplane_qrcode" int (* * * * size_t))
(define-nc ncplane_reparent "ncplane_reparent" * (* *))
(define-nc ncplane_reparent_family "ncplane_reparent_family" * (* *))
(define-nc ncplane_resize "ncplane_resize" int (* int int unsigned-int unsigned-int int int unsigned-int unsigned-int))
(define-nc ncplane_resize_marginalized "ncplane_resize_marginalized" int (*))
(define-nc ncplane_resize_maximize "ncplane_resize_maximize" int (*))
(define-nc ncplane_resize_placewithin "ncplane_resize_placewithin" int (*))
(define-nc ncplane_resize_realign "ncplane_resize_realign" int (*))
(define-nc ncplane_resize_simple "ncplane_resize_simple" int (* unsigned-int unsigned-int))
(define-nc ncplane_resizecb "ncplane_resizecb" * (*))
(define-nc ncplane_rotate_ccw "ncplane_rotate_ccw" int (*))
(define-nc ncplane_rotate_cw "ncplane_rotate_cw" int (*))
(define-nc ncplane_rounded_box "ncplane_rounded_box" int (* uint16 uint64 unsigned-int unsigned-int unsigned-int))
(define-nc ncplane_rounded_box_sized "ncplane_rounded_box_sized" int (* uint16 uint64 unsigned-int unsigned-int unsigned-int))
(define-nc ncplane_scrolling_p "ncplane_scrolling_p" bool (*))
(define-nc ncplane_scrollup "ncplane_scrollup" int (* int))
(define-nc ncplane_scrollup_child "ncplane_scrollup_child" int (* *))
(define-nc ncplane_set_autogrow "ncplane_set_autogrow" bool (* unsigned-int))
(define-nc ncplane_set_base "ncplane_set_base" int (* * uint16 uint64))
(define-nc ncplane_set_base_cell "ncplane_set_base_cell" int (* *))
(define-nc ncplane_set_bchannel "ncplane_set_bchannel" uint64 (* uint32))
(define-nc ncplane_set_bg_alpha "ncplane_set_bg_alpha" int (* int))
(define-nc ncplane_set_bg_default "ncplane_set_bg_default" void (*))
(define-nc ncplane_set_bg_palindex "ncplane_set_bg_palindex" int (* unsigned-int))
(define-nc ncplane_set_bg_rgb "ncplane_set_bg_rgb" int (* uint32))
(define-nc ncplane_set_bg_rgb8 "ncplane_set_bg_rgb8" int (* unsigned-int unsigned-int unsigned-int))
(define-nc ncplane_set_bg_rgb8_clipped "ncplane_set_bg_rgb8_clipped" void (* int int int))
(define-nc ncplane_set_channels "ncplane_set_channels" void (* uint64))
(define-nc ncplane_set_fchannel "ncplane_set_fchannel" uint64 (* uint32))
(define-nc ncplane_set_fg_alpha "ncplane_set_fg_alpha" int (* int))
(define-nc ncplane_set_fg_default "ncplane_set_fg_default" void (*))
(define-nc ncplane_set_fg_palindex "ncplane_set_fg_palindex" int (* unsigned-int))
(define-nc ncplane_set_fg_rgb "ncplane_set_fg_rgb" int (* uint32))
(define-nc ncplane_set_fg_rgb8 "ncplane_set_fg_rgb8" int (* unsigned-int unsigned-int unsigned-int))
(define-nc ncplane_set_fg_rgb8_clipped "ncplane_set_fg_rgb8_clipped" void (* int int int))
(define-nc ncplane_set_name "ncplane_set_name" int (* *))
(define-nc ncplane_set_resizecb "ncplane_set_resizecb" void (* *))
(define-nc ncplane_set_scrolling "ncplane_set_scrolling" bool (* unsigned-int))
(define-nc ncplane_set_styles "ncplane_set_styles" void (* unsigned-int))
(define-nc ncplane_set_userptr "ncplane_set_userptr" * (* *))
(define-nc ncplane_stain "ncplane_stain" int (* int int unsigned-int unsigned-int uint64 uint64 uint64 uint64))
(define-nc ncplane_styles "ncplane_styles" uint16 (*))
(define-nc ncplane_translate "ncplane_translate" void (* * * *))
(define-nc ncplane_translate_abs "ncplane_translate_abs" bool (* * *))
(define-nc ncplane_userptr "ncplane_userptr" * (*))
(define-nc ncplane_valign "ncplane_valign" int (* int int))
(define-nc ncplane_vline "ncplane_vline" int (* * unsigned-int))
(define-nc ncplane_vline_interp "ncplane_vline_interp" int (* * unsigned-int uint64 uint64))
(define-nc ncplane_vprintf "ncplane_vprintf" int (* * *))
(define-nc ncplane_vprintf_aligned "ncplane_vprintf_aligned" int (* int int * *))
(define-nc ncplane_vprintf_stained "ncplane_vprintf_stained" int (* * *))
(define-nc ncplane_vprintf_yx "ncplane_vprintf_yx" int (* int int * *))
(define-nc ncplane_x "ncplane_x" int (*))
(define-nc ncplane_y "ncplane_y" int (*))
(define-nc ncplane_yx "ncplane_yx" void (* * *))

(define (ncplane_printf n fmt . args)
  "Formatted output onto plane N at current cursor position using Guile format."
  (ncplane_putstr n (string->pointer (apply format #f fmt args))))

(define (ncplane_printf_yx n y x fmt . args)
  "Formatted output onto plane N at (Y, X) using Guile format."
  (ncplane_putstr_yx n y x (string->pointer (apply format #f fmt args))))

(define (ncplane_printf_aligned n y align fmt . args)
  "Formatted aligned output onto plane N on row Y using Guile format."
  (ncplane_putstr_aligned n y align (string->pointer (apply format #f fmt args))))

(define (ncplane_printf_stained n fmt . args)
  "Formatted stained output onto plane N using Guile format."
  (ncplane_putstr_stained n (string->pointer (apply format #f fmt args))))
