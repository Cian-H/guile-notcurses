;;; notcurses/core.scm — Core lifecycle, rendering, cursor, palette, stats, capabilities, and piles.

(define-module (notcurses core)
  #:use-module (system foreign)
  #:use-module (notcurses ffi)
  #:export (ncblit_bgrx
            ncblit_rgb_loose
            ncblit_rgb_packed
            ncblit_rgba
            ncbprefix
            nccapability_canchangecolor
            nccellcmp
            nciprefix
            ncnmetric
            ncpalette_free
            ncpalette_get
            ncpalette_get_rgb8
            ncpalette_new
            ncpalette_set
            ncpalette_set_rgb8
            ncpalette_use
            ncpile_bottom
            ncpile_create
            ncpile_rasterize
            ncpile_render
            ncpile_render_to_buffer
            ncpile_render_to_file
            ncpile_top
            ncqprefix
            ncstrwidth
            ncvisualplane_create
            ncwcsrtombs
            notcurses_accountname
            notcurses_align
            notcurses_at_yx
            notcurses_bottom
            notcurses_canbraille
            notcurses_canchangecolor
            notcurses_canfade
            notcurses_canhalfblock
            notcurses_canoctant
            notcurses_canopen_images
            notcurses_canopen_videos
            notcurses_canpixel
            notcurses_canquadrant
            notcurses_cansextant
            notcurses_cantruecolor
            notcurses_canutf8
            notcurses_capabilities
            notcurses_check_pixel_support
            notcurses_core_init
            notcurses_cursor_disable
            notcurses_cursor_enable
            notcurses_cursor_yx
            notcurses_debug
            notcurses_default_background
            notcurses_default_foreground
            notcurses_detected_terminal
            notcurses_drop_planes
            notcurses_enter_alternate_screen
            notcurses_hostname
            notcurses_init
            notcurses_leave_alternate_screen
            notcurses_lex_blitter
            notcurses_lex_margins
            notcurses_lex_scalemode
            notcurses_osversion
            notcurses_palette_size
            notcurses_refresh
            notcurses_render
            notcurses_stats
            notcurses_stats_alloc
            notcurses_stats_reset
            notcurses_stddim_yx
            notcurses_stddim_yx_const
            notcurses_stdplane
            notcurses_stdplane_const
            notcurses_stop
            notcurses_str_blitter
            notcurses_str_scalemode
            notcurses_supported_styles
            notcurses_term_dim_yx
            notcurses_top
            notcurses_ucs32_to_utf8
            notcurses_version
            notcurses_version_components))

(define-nc ncblit_bgrx "ncblit_bgrx" int (* int *))
(define-nc ncblit_rgb_loose "ncblit_rgb_loose" int (* int * int))
(define-nc ncblit_rgb_packed "ncblit_rgb_packed" int (* int * int))
(define-nc ncblit_rgba "ncblit_rgba" int (* int *))
(define-nc ncbprefix "ncbprefix" * (uint64 uint64 * int))
(define-nc nccapability_canchangecolor "nccapability_canchangecolor" bool (*))
(define-nc nccellcmp "nccellcmp" bool (* * * *))
(define-nc nciprefix "nciprefix" * (uint64 uint64 * int))
(define-nc ncnmetric "ncnmetric" * (uint64 size_t uint64 * int uint64 int))
(define-nc ncpalette_free "ncpalette_free" void (*))
(define-nc ncpalette_get "ncpalette_get" int (* int *))
(define-nc ncpalette_get_rgb8 "ncpalette_get_rgb8" int (* int * * *))
(define-nc ncpalette_new "ncpalette_new" * (*))
(define-nc ncpalette_set "ncpalette_set" int (* int unsigned-int))
(define-nc ncpalette_set_rgb8 "ncpalette_set_rgb8" int (* int unsigned-int unsigned-int unsigned-int))
(define-nc ncpalette_use "ncpalette_use" int (* *))
(define-nc ncpile_bottom "ncpile_bottom" * (*))
(define-nc ncpile_create "ncpile_create" * (* *))
(define-nc ncpile_rasterize "ncpile_rasterize" int (*))
(define-nc ncpile_render "ncpile_render" int (*))
(define-nc ncpile_render_to_buffer "ncpile_render_to_buffer" int (* * *))
(define-nc ncpile_render_to_file "ncpile_render_to_file" int (* *))
(define-nc ncpile_top "ncpile_top" * (*))
(define-nc ncqprefix "ncqprefix" * (uint64 uint64 * int))
(define-nc ncstrwidth "ncstrwidth" int (* * *))
(define-nc ncvisualplane_create "ncvisualplane_create" * (* * * *))
(define-nc ncwcsrtombs "ncwcsrtombs" * (*))
(define-nc notcurses_accountname "notcurses_accountname" * ())
(define-nc notcurses_align "notcurses_align" int (int int int))
(define-nc notcurses_at_yx "notcurses_at_yx" * (* unsigned-int unsigned-int * *))
(define-nc notcurses_bottom "notcurses_bottom" * (*))
(define-nc notcurses_canbraille "notcurses_canbraille" bool (*))
(define-nc notcurses_canchangecolor "notcurses_canchangecolor" bool (*))
(define-nc notcurses_canfade "notcurses_canfade" bool (*))
(define-nc notcurses_canhalfblock "notcurses_canhalfblock" bool (*))
(define-nc notcurses_canoctant "notcurses_canoctant" bool (*))
(define-nc notcurses_canopen_images "notcurses_canopen_images" bool (*))
(define-nc notcurses_canopen_videos "notcurses_canopen_videos" bool (*))
(define-nc notcurses_canpixel "notcurses_canpixel" bool (*))
(define-nc notcurses_canquadrant "notcurses_canquadrant" bool (*))
(define-nc notcurses_cansextant "notcurses_cansextant" bool (*))
(define-nc notcurses_cantruecolor "notcurses_cantruecolor" bool (*))
(define-nc notcurses_canutf8 "notcurses_canutf8" bool (*))
(define-nc notcurses_capabilities "notcurses_capabilities" * (*))
(define-nc notcurses_check_pixel_support "notcurses_check_pixel_support" int (*))
(define-nc notcurses_core_init "notcurses_core_init" * (* *))
(define-nc notcurses_cursor_disable "notcurses_cursor_disable" int (*))
(define-nc notcurses_cursor_enable "notcurses_cursor_enable" int (* int int))
(define-nc notcurses_cursor_yx "notcurses_cursor_yx" int (* * *))
(define-nc notcurses_debug "notcurses_debug" void (* *))
(define-nc notcurses_default_background "notcurses_default_background" int (* *))
(define-nc notcurses_default_foreground "notcurses_default_foreground" int (* *))
(define-nc notcurses_detected_terminal "notcurses_detected_terminal" * (*))
(define-nc notcurses_drop_planes "notcurses_drop_planes" void (*))
(define-nc notcurses_enter_alternate_screen "notcurses_enter_alternate_screen" int (*))
(define-nc notcurses_hostname "notcurses_hostname" * ())
(define-nc notcurses_init "notcurses_init" * (* *))
(define-nc notcurses_leave_alternate_screen "notcurses_leave_alternate_screen" int (*))
(define-nc notcurses_lex_blitter "notcurses_lex_blitter" int (* *))
(define-nc notcurses_lex_margins "notcurses_lex_margins" int (* *))
(define-nc notcurses_lex_scalemode "notcurses_lex_scalemode" int (* *))
(define-nc notcurses_osversion "notcurses_osversion" * ())
(define-nc notcurses_palette_size "notcurses_palette_size" unsigned-int (*))
(define-nc notcurses_refresh "notcurses_refresh" int (* * *))
(define-nc notcurses_render "notcurses_render" int (*))
(define-nc notcurses_stats "notcurses_stats" void (* *))
(define-nc notcurses_stats_alloc "notcurses_stats_alloc" * (*))
(define-nc notcurses_stats_reset "notcurses_stats_reset" void (* *))
(define-nc notcurses_stddim_yx "notcurses_stddim_yx" * (* * *))
(define-nc notcurses_stddim_yx_const "notcurses_stddim_yx_const" * (* * *))
(define-nc notcurses_stdplane "notcurses_stdplane" * (*))
(define-nc notcurses_stdplane_const "notcurses_stdplane_const" * (*))
(define-nc notcurses_stop "notcurses_stop" int (*))
(define-nc notcurses_str_blitter "notcurses_str_blitter" * (int))
(define-nc notcurses_str_scalemode "notcurses_str_scalemode" * (int))
(define-nc notcurses_supported_styles "notcurses_supported_styles" uint16 (*))
(define-nc notcurses_term_dim_yx "notcurses_term_dim_yx" void (* * *))
(define-nc notcurses_top "notcurses_top" * (*))
(define-nc notcurses_ucs32_to_utf8 "notcurses_ucs32_to_utf8" int (* unsigned-int * size_t))
(define-nc notcurses_version "notcurses_version" * ())
(define-nc notcurses_version_components "notcurses_version_components" void (* * * *))
