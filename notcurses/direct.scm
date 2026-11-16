;;; notcurses/direct.scm — ncdirect non-fullscreen direct-mode terminal output.

(define-module (notcurses direct)
  #:use-module (system foreign)
  #:use-module (notcurses ffi)
  #:export (ncdirect_ascii_box
            ncdirect_box
            ncdirect_canbraille
            ncdirect_canchangecolor
            ncdirect_canfade
            ncdirect_canget_cursor
            ncdirect_canhalfblock
            ncdirect_canoctant
            ncdirect_canopen_images
            ncdirect_canopen_videos
            ncdirect_canquadrant
            ncdirect_cansextant
            ncdirect_cantruecolor
            ncdirect_canutf8
            ncdirect_capabilities
            ncdirect_check_pixel_support
            ncdirect_clear
            ncdirect_core_init
            ncdirect_cursor_disable
            ncdirect_cursor_down
            ncdirect_cursor_enable
            ncdirect_cursor_left
            ncdirect_cursor_move_yx
            ncdirect_cursor_pop
            ncdirect_cursor_push
            ncdirect_cursor_right
            ncdirect_cursor_up
            ncdirect_cursor_yx
            ncdirect_detected_terminal
            ncdirect_dim_x
            ncdirect_dim_y
            ncdirect_double_box
            ncdirect_flush
            ncdirect_get
            ncdirect_get_blocking
            ncdirect_get_nblock
            ncdirect_heavy_box
            ncdirect_hline_interp
            ncdirect_init
            ncdirect_inputready_fd
            ncdirect_light_box
            ncdirect_off_styles
            ncdirect_on_styles
            ncdirect_palette_size
            ncdirect_putegc
            ncdirect_putstr
            ncdirect_raster_frame
            ncdirect_readline
            ncdirect_render_frame
            ncdirect_render_image
            ncdirect_rounded_box
            ncdirect_set_bg_default
            ncdirect_set_bg_palindex
            ncdirect_set_bg_rgb
            ncdirect_set_bg_rgb8
            ncdirect_set_fg_default
            ncdirect_set_fg_palindex
            ncdirect_set_fg_rgb
            ncdirect_set_fg_rgb8
            ncdirect_set_styles
            ncdirect_stop
            ncdirect_stream
            ncdirect_styles
            ncdirect_supported_styles
            ncdirect_vline_interp
            ncdirectf_free
            ncdirectf_from_file
            ncdirectf_geom
            ncdirectf_render
            ncdirect_printf_aligned))

(define-nc ncdirect_ascii_box "ncdirect_ascii_box" int (* uint64 uint64 uint64 uint64 unsigned-int unsigned-int unsigned-int))
(define-nc ncdirect_box "ncdirect_box" int (* uint64 uint64 uint64 uint64 * unsigned-int unsigned-int unsigned-int))
(define-nc ncdirect_canbraille "ncdirect_canbraille" bool (*))
(define-nc ncdirect_canchangecolor "ncdirect_canchangecolor" bool (*))
(define-nc ncdirect_canfade "ncdirect_canfade" bool (*))
(define-nc ncdirect_canget_cursor "ncdirect_canget_cursor" bool (*))
(define-nc ncdirect_canhalfblock "ncdirect_canhalfblock" bool (*))
(define-nc ncdirect_canoctant "ncdirect_canoctant" bool (*))
(define-nc ncdirect_canopen_images "ncdirect_canopen_images" bool (*))
(define-nc ncdirect_canopen_videos "ncdirect_canopen_videos" bool (*))
(define-nc ncdirect_canquadrant "ncdirect_canquadrant" bool (*))
(define-nc ncdirect_cansextant "ncdirect_cansextant" bool (*))
(define-nc ncdirect_cantruecolor "ncdirect_cantruecolor" bool (*))
(define-nc ncdirect_canutf8 "ncdirect_canutf8" bool (*))
(define-nc ncdirect_capabilities "ncdirect_capabilities" * (*))
(define-nc ncdirect_check_pixel_support "ncdirect_check_pixel_support" int (*))
(define-nc ncdirect_clear "ncdirect_clear" int (*))
(define-nc ncdirect_core_init "ncdirect_core_init" * (* * uint64))
(define-nc ncdirect_cursor_disable "ncdirect_cursor_disable" int (*))
(define-nc ncdirect_cursor_down "ncdirect_cursor_down" int (* int))
(define-nc ncdirect_cursor_enable "ncdirect_cursor_enable" int (*))
(define-nc ncdirect_cursor_left "ncdirect_cursor_left" int (* int))
(define-nc ncdirect_cursor_move_yx "ncdirect_cursor_move_yx" int (* int int))
(define-nc ncdirect_cursor_pop "ncdirect_cursor_pop" int (*))
(define-nc ncdirect_cursor_push "ncdirect_cursor_push" int (*))
(define-nc ncdirect_cursor_right "ncdirect_cursor_right" int (* int))
(define-nc ncdirect_cursor_up "ncdirect_cursor_up" int (* int))
(define-nc ncdirect_cursor_yx "ncdirect_cursor_yx" int (* * *))
(define-nc ncdirect_detected_terminal "ncdirect_detected_terminal" * (*))
(define-nc ncdirect_dim_x "ncdirect_dim_x" unsigned-int (*))
(define-nc ncdirect_dim_y "ncdirect_dim_y" unsigned-int (*))
(define-nc ncdirect_double_box "ncdirect_double_box" int (* uint64 uint64 uint64 uint64 unsigned-int unsigned-int unsigned-int))
(define-nc ncdirect_flush "ncdirect_flush" int (*))
(define-nc ncdirect_get "ncdirect_get" uint32 (* * *))
(define-nc ncdirect_get_blocking "ncdirect_get_blocking" uint32 (* *))
(define-nc ncdirect_get_nblock "ncdirect_get_nblock" uint32 (* *))
(define-nc ncdirect_heavy_box "ncdirect_heavy_box" int (* uint64 uint64 uint64 uint64 unsigned-int unsigned-int unsigned-int))
(define-nc ncdirect_hline_interp "ncdirect_hline_interp" int (* * unsigned-int uint64 uint64))
(define-nc ncdirect_init "ncdirect_init" * (* * uint64))
(define-nc ncdirect_inputready_fd "ncdirect_inputready_fd" int (*))
(define-nc ncdirect_light_box "ncdirect_light_box" int (* uint64 uint64 uint64 uint64 unsigned-int unsigned-int unsigned-int))
(define-nc ncdirect_off_styles "ncdirect_off_styles" int (* unsigned-int))
(define-nc ncdirect_on_styles "ncdirect_on_styles" int (* unsigned-int))
(define-nc ncdirect_palette_size "ncdirect_palette_size" unsigned-int (*))
(define-nc ncdirect_putegc "ncdirect_putegc" int (* uint64 * *))
(define-nc ncdirect_putstr "ncdirect_putstr" int (* uint64 *))
(define-nc ncdirect_raster_frame "ncdirect_raster_frame" int (* * int))
(define-nc ncdirect_readline "ncdirect_readline" * (* *))
(define-nc ncdirect_render_frame "ncdirect_render_frame" * (* * int int int int))
(define-nc ncdirect_render_image "ncdirect_render_image" int (* * int int int))
(define-nc ncdirect_rounded_box "ncdirect_rounded_box" int (* uint64 uint64 uint64 uint64 unsigned-int unsigned-int unsigned-int))
(define-nc ncdirect_set_bg_default "ncdirect_set_bg_default" int (*))
(define-nc ncdirect_set_bg_palindex "ncdirect_set_bg_palindex" int (* int))
(define-nc ncdirect_set_bg_rgb "ncdirect_set_bg_rgb" int (* unsigned-int))
(define-nc ncdirect_set_bg_rgb8 "ncdirect_set_bg_rgb8" int (* unsigned-int unsigned-int unsigned-int))
(define-nc ncdirect_set_fg_default "ncdirect_set_fg_default" int (*))
(define-nc ncdirect_set_fg_palindex "ncdirect_set_fg_palindex" int (* int))
(define-nc ncdirect_set_fg_rgb "ncdirect_set_fg_rgb" int (* unsigned-int))
(define-nc ncdirect_set_fg_rgb8 "ncdirect_set_fg_rgb8" int (* unsigned-int unsigned-int unsigned-int))
(define-nc ncdirect_set_styles "ncdirect_set_styles" int (* unsigned-int))
(define-nc ncdirect_stop "ncdirect_stop" int (*))
(define-nc ncdirect_stream "ncdirect_stream" int (* * * * *))
(define-nc ncdirect_styles "ncdirect_styles" uint16 (*))
(define-nc ncdirect_supported_styles "ncdirect_supported_styles" uint16 (*))
(define-nc ncdirect_vline_interp "ncdirect_vline_interp" int (* * unsigned-int uint64 uint64))
(define-nc ncdirectf_free "ncdirectf_free" void (*))
(define-nc ncdirectf_from_file "ncdirectf_from_file" * (* *))
(define-nc ncdirectf_geom "ncdirectf_geom" int (* * * *))
(define-nc ncdirectf_render "ncdirectf_render" * (* * *))

(define (ncdirect_printf_aligned n y align fmt . args)
  "Formatted aligned output in direct mode using Guile format."
  (let* ((s (apply format #f fmt args))
         (cols (ncdirect_dim_x n))
         (len (string-length s))
         (x (case align
              ((1) 0)
              ((2) (max 0 (quotient (- cols len) 2)))
              ((3) (max 0 (- cols len)))
              (else -1))))
    (when (or (>= y 0) (>= x 0))
      (ncdirect_cursor_move_yx n y (if (< x 0) 0 x)))
    (ncdirect_putstr n 0 (string->pointer s))))
