;;; notcurses/visual.scm — ncvisual image/video blitting, scaling, pixel manipulation.

(define-module (notcurses visual)
  #:use-module (system foreign)
  #:use-module (notcurses ffi)
  #:export (ncpixel
            ncpixel_a
            ncpixel_b
            ncpixel_g
            ncpixel_r
            ncpixel_set_a
            ncpixel_set_b
            ncpixel_set_g
            ncpixel_set_r
            ncpixel_set_rgb8
            ncvisual_at_yx
            ncvisual_blit
            ncvisual_decode
            ncvisual_decode_loop
            ncvisual_destroy
            ncvisual_from_bgra
            ncvisual_from_file
            ncvisual_from_palidx
            ncvisual_from_plane
            ncvisual_from_rgb_loose
            ncvisual_from_rgb_packed
            ncvisual_from_rgba
            ncvisual_from_sixel
            ncvisual_geom
            ncvisual_media_defblitter
            ncvisual_polyfill_yx
            ncvisual_resize
            ncvisual_resize_noninterpolative
            ncvisual_rotate
            ncvisual_set_yx
            ncvisual_simple_streamer
            ncvisual_stream
            ncvisual_subtitle_plane))

(define-nc ncpixel "ncpixel" uint32 (unsigned-int unsigned-int unsigned-int))
(define-nc ncpixel_a "ncpixel_a" unsigned-int (uint32))
(define-nc ncpixel_b "ncpixel_b" unsigned-int (uint32))
(define-nc ncpixel_g "ncpixel_g" unsigned-int (uint32))
(define-nc ncpixel_r "ncpixel_r" unsigned-int (uint32))
(define-nc ncpixel_set_a "ncpixel_set_a" int (* unsigned-int))
(define-nc ncpixel_set_b "ncpixel_set_b" int (* unsigned-int))
(define-nc ncpixel_set_g "ncpixel_set_g" int (* unsigned-int))
(define-nc ncpixel_set_r "ncpixel_set_r" int (* unsigned-int))
(define-nc ncpixel_set_rgb8 "ncpixel_set_rgb8" int (* unsigned-int unsigned-int unsigned-int))
(define-nc ncvisual_at_yx "ncvisual_at_yx" int (* unsigned-int unsigned-int *))
(define-nc ncvisual_blit "ncvisual_blit" * (* * *))
(define-nc ncvisual_decode "ncvisual_decode" int (*))
(define-nc ncvisual_decode_loop "ncvisual_decode_loop" int (*))
(define-nc ncvisual_destroy "ncvisual_destroy" void (*))
(define-nc ncvisual_from_bgra "ncvisual_from_bgra" * (* int int int))
(define-nc ncvisual_from_file "ncvisual_from_file" * (*))
(define-nc ncvisual_from_palidx "ncvisual_from_palidx" * (* int int int int int *))
(define-nc ncvisual_from_plane "ncvisual_from_plane" * (* int int int unsigned-int unsigned-int))
(define-nc ncvisual_from_rgb_loose "ncvisual_from_rgb_loose" * (* int int int int))
(define-nc ncvisual_from_rgb_packed "ncvisual_from_rgb_packed" * (* int int int int))
(define-nc ncvisual_from_rgba "ncvisual_from_rgba" * (* int int int))
(define-nc ncvisual_from_sixel "ncvisual_from_sixel" * (* unsigned-int unsigned-int))
(define-nc ncvisual_geom "ncvisual_geom" int (* * * *))
(define-nc ncvisual_media_defblitter "ncvisual_media_defblitter" int (* int))
(define-nc ncvisual_polyfill_yx "ncvisual_polyfill_yx" int (* unsigned-int unsigned-int uint32))
(define-nc ncvisual_resize "ncvisual_resize" int (* int int))
(define-nc ncvisual_resize_noninterpolative "ncvisual_resize_noninterpolative" int (* int int))
(define-nc ncvisual_rotate "ncvisual_rotate" int (* double))
(define-nc ncvisual_set_yx "ncvisual_set_yx" int (* unsigned-int unsigned-int uint32))
(define-nc ncvisual_simple_streamer "ncvisual_simple_streamer" int (* * * *))
(define-nc ncvisual_stream "ncvisual_stream" int (* * float * * *))
(define-nc ncvisual_subtitle_plane "ncvisual_subtitle_plane" * (* *))
