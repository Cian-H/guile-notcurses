;;; notcurses/widgets.scm — High-level notcurses widgets (menu, selector, reader, tree, plot, reel, etc.).

(define-module (notcurses widgets)
  #:use-module (system foreign)
  #:use-module (notcurses ffi)
  #:export (ncdplot_add_sample
            ncdplot_create
            ncdplot_destroy
            ncdplot_plane
            ncdplot_sample
            ncdplot_set_sample
            ncfadectx_free
            ncfadectx_iterations
            ncfadectx_setup
            ncfdplane_create
            ncfdplane_destroy
            ncfdplane_plane
            ncmenu_create
            ncmenu_destroy
            ncmenu_item_set_status
            ncmenu_mouse_selected
            ncmenu_nextitem
            ncmenu_nextsection
            ncmenu_offer_input
            ncmenu_plane
            ncmenu_previtem
            ncmenu_prevsection
            ncmenu_rollup
            ncmenu_selected
            ncmenu_unroll
            ncmultiselector_create
            ncmultiselector_destroy
            ncmultiselector_offer_input
            ncmultiselector_plane
            ncmultiselector_selected
            ncprogbar_create
            ncprogbar_destroy
            ncprogbar_plane
            ncprogbar_progress
            ncprogbar_set_progress
            ncreader_clear
            ncreader_contents
            ncreader_create
            ncreader_destroy
            ncreader_move_down
            ncreader_move_left
            ncreader_move_right
            ncreader_move_up
            ncreader_offer_input
            ncreader_plane
            ncreader_write_egc
            ncreel_add
            ncreel_create
            ncreel_del
            ncreel_destroy
            ncreel_focused
            ncreel_next
            ncreel_offer_input
            ncreel_plane
            ncreel_prev
            ncreel_redraw
            ncreel_tabletcount
            ncselector_additem
            ncselector_create
            ncselector_delitem
            ncselector_destroy
            ncselector_nextitem
            ncselector_offer_input
            ncselector_plane
            ncselector_previtem
            ncselector_selected
            ncsubproc_createv
            ncsubproc_createvp
            ncsubproc_createvpe
            ncsubproc_destroy
            ncsubproc_plane
            nctab_cb
            nctab_move
            nctab_move_left
            nctab_move_right
            nctab_name
            nctab_name_width
            nctab_next
            nctab_prev
            nctab_set_cb
            nctab_set_name
            nctab_set_userptr
            nctab_userptr
            nctabbed_add
            nctabbed_channels
            nctabbed_content_plane
            nctabbed_create
            nctabbed_del
            nctabbed_destroy
            nctabbed_ensure_selected_header_visible
            nctabbed_hdrchan
            nctabbed_leftmost
            nctabbed_next
            nctabbed_plane
            nctabbed_prev
            nctabbed_redraw
            nctabbed_rotate
            nctabbed_selchan
            nctabbed_select
            nctabbed_selected
            nctabbed_separator
            nctabbed_separator_width
            nctabbed_sepchan
            nctabbed_set_hdrchan
            nctabbed_set_selchan
            nctabbed_set_separator
            nctabbed_set_sepchan
            nctabbed_tabcount
            nctablet_plane
            nctablet_userptr
            nctree_add
            nctree_create
            nctree_del
            nctree_destroy
            nctree_focused
            nctree_goto
            nctree_next
            nctree_offer_input
            nctree_plane
            nctree_prev
            nctree_redraw
            ncuplot_add_sample
            ncuplot_create
            ncuplot_destroy
            ncuplot_plane
            ncuplot_sample
            ncuplot_set_sample))

(define-nc ncdplot_add_sample "ncdplot_add_sample" int (* uint64 double))
(define-nc ncdplot_create "ncdplot_create" * (* * double double))
(define-nc ncdplot_destroy "ncdplot_destroy" void (*))
(define-nc ncdplot_plane "ncdplot_plane" * (*))
(define-nc ncdplot_sample "ncdplot_sample" int (* uint64 *))
(define-nc ncdplot_set_sample "ncdplot_set_sample" int (* uint64 double))
(define-nc ncfadectx_free "ncfadectx_free" void (*))
(define-nc ncfadectx_iterations "ncfadectx_iterations" int (*))
(define-nc ncfadectx_setup "ncfadectx_setup" * (*))
(define-nc ncfdplane_create "ncfdplane_create" * (* * int * *))
(define-nc ncfdplane_destroy "ncfdplane_destroy" int (*))
(define-nc ncfdplane_plane "ncfdplane_plane" * (*))
(define-nc ncmenu_create "ncmenu_create" * (* *))
(define-nc ncmenu_destroy "ncmenu_destroy" void (*))
(define-nc ncmenu_item_set_status "ncmenu_item_set_status" int (* * * bool))
(define-nc ncmenu_mouse_selected "ncmenu_mouse_selected" * (* * *))
(define-nc ncmenu_nextitem "ncmenu_nextitem" int (*))
(define-nc ncmenu_nextsection "ncmenu_nextsection" int (*))
(define-nc ncmenu_offer_input "ncmenu_offer_input" bool (* *))
(define-nc ncmenu_plane "ncmenu_plane" * (*))
(define-nc ncmenu_previtem "ncmenu_previtem" int (*))
(define-nc ncmenu_prevsection "ncmenu_prevsection" int (*))
(define-nc ncmenu_rollup "ncmenu_rollup" int (*))
(define-nc ncmenu_selected "ncmenu_selected" * (* *))
(define-nc ncmenu_unroll "ncmenu_unroll" int (* int))
(define-nc ncmultiselector_create "ncmultiselector_create" * (* *))
(define-nc ncmultiselector_destroy "ncmultiselector_destroy" void (*))
(define-nc ncmultiselector_offer_input "ncmultiselector_offer_input" bool (* *))
(define-nc ncmultiselector_plane "ncmultiselector_plane" * (*))
(define-nc ncmultiselector_selected "ncmultiselector_selected" int (* * unsigned-int))
(define-nc ncprogbar_create "ncprogbar_create" * (* *))
(define-nc ncprogbar_destroy "ncprogbar_destroy" void (*))
(define-nc ncprogbar_plane "ncprogbar_plane" * (*))
(define-nc ncprogbar_progress "ncprogbar_progress" double (*))
(define-nc ncprogbar_set_progress "ncprogbar_set_progress" int (* double))
(define-nc ncreader_clear "ncreader_clear" int (*))
(define-nc ncreader_contents "ncreader_contents" * (*))
(define-nc ncreader_create "ncreader_create" * (* *))
(define-nc ncreader_destroy "ncreader_destroy" void (* *))
(define-nc ncreader_move_down "ncreader_move_down" int (*))
(define-nc ncreader_move_left "ncreader_move_left" int (*))
(define-nc ncreader_move_right "ncreader_move_right" int (*))
(define-nc ncreader_move_up "ncreader_move_up" int (*))
(define-nc ncreader_offer_input "ncreader_offer_input" bool (* *))
(define-nc ncreader_plane "ncreader_plane" * (*))
(define-nc ncreader_write_egc "ncreader_write_egc" int (* *))
(define-nc ncreel_add "ncreel_add" * (* * * * *))
(define-nc ncreel_create "ncreel_create" * (* *))
(define-nc ncreel_del "ncreel_del" int (* *))
(define-nc ncreel_destroy "ncreel_destroy" void (*))
(define-nc ncreel_focused "ncreel_focused" * (*))
(define-nc ncreel_next "ncreel_next" * (*))
(define-nc ncreel_offer_input "ncreel_offer_input" bool (* *))
(define-nc ncreel_plane "ncreel_plane" * (*))
(define-nc ncreel_prev "ncreel_prev" * (*))
(define-nc ncreel_redraw "ncreel_redraw" int (*))
(define-nc ncreel_tabletcount "ncreel_tabletcount" int (*))
(define-nc ncselector_additem "ncselector_additem" int (* *))
(define-nc ncselector_create "ncselector_create" * (* *))
(define-nc ncselector_delitem "ncselector_delitem" int (* *))
(define-nc ncselector_destroy "ncselector_destroy" void (* *))
(define-nc ncselector_nextitem "ncselector_nextitem" * (*))
(define-nc ncselector_offer_input "ncselector_offer_input" bool (* *))
(define-nc ncselector_plane "ncselector_plane" * (*))
(define-nc ncselector_previtem "ncselector_previtem" * (*))
(define-nc ncselector_selected "ncselector_selected" * (*))
(define-nc ncsubproc_createv "ncsubproc_createv" * (* * * * * *))
(define-nc ncsubproc_createvp "ncsubproc_createvp" * (* * * * * *))
(define-nc ncsubproc_createvpe "ncsubproc_createvpe" * (* * * * * * *))
(define-nc ncsubproc_destroy "ncsubproc_destroy" int (*))
(define-nc ncsubproc_plane "ncsubproc_plane" * (*))
(define-nc nctab_cb "nctab_cb" * (*))
(define-nc nctab_move "nctab_move" int (* * * *))
(define-nc nctab_move_left "nctab_move_left" void (* *))
(define-nc nctab_move_right "nctab_move_right" void (* *))
(define-nc nctab_name "nctab_name" * (*))
(define-nc nctab_name_width "nctab_name_width" int (*))
(define-nc nctab_next "nctab_next" * (*))
(define-nc nctab_prev "nctab_prev" * (*))
(define-nc nctab_set_cb "nctab_set_cb" * (* *))
(define-nc nctab_set_name "nctab_set_name" int (* *))
(define-nc nctab_set_userptr "nctab_set_userptr" * (* *))
(define-nc nctab_userptr "nctab_userptr" * (*))
(define-nc nctabbed_add "nctabbed_add" * (* * * * * *))
(define-nc nctabbed_channels "nctabbed_channels" void (* * * *))
(define-nc nctabbed_content_plane "nctabbed_content_plane" * (*))
(define-nc nctabbed_create "nctabbed_create" * (* *))
(define-nc nctabbed_del "nctabbed_del" int (* *))
(define-nc nctabbed_destroy "nctabbed_destroy" void (*))
(define-nc nctabbed_ensure_selected_header_visible "nctabbed_ensure_selected_header_visible" void (*))
(define-nc nctabbed_hdrchan "nctabbed_hdrchan" uint64 (*))
(define-nc nctabbed_leftmost "nctabbed_leftmost" * (*))
(define-nc nctabbed_next "nctabbed_next" * (*))
(define-nc nctabbed_plane "nctabbed_plane" * (*))
(define-nc nctabbed_prev "nctabbed_prev" * (*))
(define-nc nctabbed_redraw "nctabbed_redraw" void (*))
(define-nc nctabbed_rotate "nctabbed_rotate" void (* int))
(define-nc nctabbed_selchan "nctabbed_selchan" uint64 (*))
(define-nc nctabbed_select "nctabbed_select" * (* *))
(define-nc nctabbed_selected "nctabbed_selected" * (*))
(define-nc nctabbed_separator "nctabbed_separator" * (*))
(define-nc nctabbed_separator_width "nctabbed_separator_width" int (*))
(define-nc nctabbed_sepchan "nctabbed_sepchan" uint64 (*))
(define-nc nctabbed_set_hdrchan "nctabbed_set_hdrchan" void (* uint64))
(define-nc nctabbed_set_selchan "nctabbed_set_selchan" void (* uint64))
(define-nc nctabbed_set_separator "nctabbed_set_separator" int (* *))
(define-nc nctabbed_set_sepchan "nctabbed_set_sepchan" void (* uint64))
(define-nc nctabbed_tabcount "nctabbed_tabcount" int (*))
(define-nc nctablet_plane "nctablet_plane" * (*))
(define-nc nctablet_userptr "nctablet_userptr" * (*))
(define-nc nctree_add "nctree_add" int (* * *))
(define-nc nctree_create "nctree_create" * (* *))
(define-nc nctree_del "nctree_del" int (* *))
(define-nc nctree_destroy "nctree_destroy" void (*))
(define-nc nctree_focused "nctree_focused" * (*))
(define-nc nctree_goto "nctree_goto" * (* * *))
(define-nc nctree_next "nctree_next" * (*))
(define-nc nctree_offer_input "nctree_offer_input" bool (* *))
(define-nc nctree_plane "nctree_plane" * (*))
(define-nc nctree_prev "nctree_prev" * (*))
(define-nc nctree_redraw "nctree_redraw" int (*))
(define-nc ncuplot_add_sample "ncuplot_add_sample" int (* uint64 uint64))
(define-nc ncuplot_create "ncuplot_create" * (* * uint64 uint64))
(define-nc ncuplot_destroy "ncuplot_destroy" void (*))
(define-nc ncuplot_plane "ncuplot_plane" * (*))
(define-nc ncuplot_sample "ncuplot_sample" int (* uint64 *))
(define-nc ncuplot_set_sample "ncuplot_set_sample" int (* uint64 uint64))
