# guile-notcurses

A complete, comprehensive thin GNU Guile 3.x FFI wrapper around `libnotcurses` 3.x (`libnotcurses`, `libnotcurses-core`, and `libnotcurses-ffi`).

## Modules

- `(notcurses)` — Umbrella module re-exporting all submodules below.
- `(notcurses ffi)` — Library discovery (`GUIX_ENVIRONMENT`, `~/.guix-profile`, system loader) and FFI helpers (`define-nc`, `->c-string`, `c-string->scheme`, `c-string-free->scheme`).
- `(notcurses constants)` — All `NC*` / `NOTCURSES_*` constants, enums, and `NCKEY_*` preterunicode keycodes from `notcurses.h`, `direct.h`, `nckeys.h`, and `version.h`.
- `(notcurses structs)` — Bytevector-backed C struct constructors, field getters/setters, and `->pointer` helpers (`notcurses_options`, `ncplane_options`, `nccell`, `ncinput`, `ncvisual_options`, `ncvgeom`, `nccapabilities`, `ncpalette`, `ncstats`, and widget options/items).
- `(notcurses core)` — `notcurses_*` lifecycle, rendering, cursor, palette, stats, capabilities, `ncpile_*`, `ncmetric`, `ncstrwidth`.
- `(notcurses channel)` — `ncchannel_*` and `ncchannels_*`.
- `(notcurses cell)` — `nccell_*` and `nccells_*`.
- `(notcurses plane)` — `ncplane_*` (including Scheme `ncplane_printf*` wrappers).
- `(notcurses input)` — `notcurses_get*`, `ncinput_*`, `nckey_*`, mouse & signal controls.
- `(notcurses visual)` — `ncvisual_*` and `ncpixel*`.
- `(notcurses direct)` — `ncdirect_*` (including Scheme `ncdirect_printf_aligned`).
- `(notcurses widgets)` — `ncmenu_*`, `ncselector_*`, `ncmultiselector_*`, `ncreader_*`, `nctree_*`, `ncprogbar_*`, `nctabbed_*`, `nctab_*`, `ncuplot_*`, `ncdplot_*`, `ncreel_*`, `nctablet_*`, `ncfadectx_*`, `ncfdplane_*`, `ncsubproc_*`.
- `(notcurses terminal)` — Terminal helpers (`redirect-stderr-for-tui!`, `restore-stderr-for-tui!`, `cursor-shape`, `beep`, `sync-known-size!`, `terminal-size-changed?`, `sleep-ms`).
- `(notcurses compat curses)` — Optional curses-compatible wrapper built on `(notcurses)` (extracted from `badb`'s `(geasa surfaces-tui nc)`).

## Usage

```scheme
(use-modules (notcurses))

(let* ((opts (make-notcurses-options #:flags NCOPTION_SUPPRESS_BANNERS))
       (nc (notcurses_init (nc-struct-ptr opts) %null-pointer)))
  (unless (null-pointer? nc)
    (let ((std (notcurses_stdplane nc)))
      (ncplane_putstr_yx std 0 0 (string->pointer "Hello from guile-notcurses!"))
      (notcurses_render nc)
      (notcurses_stop nc))))
```

## Pre-compiling & Testing

Pre-compile all modules to `.go` bytecode in `ccache/`:

```bash
./scripts/precompile
```

Run the full suite (SRFI-64 unit/struct/live-PTY tests + `tui-test` E2E):

```bash
./scripts/test
```

When using Guix (e.g., via `badb`'s `scripts/devenv`):

```bash
/path/to/badb/scripts/devenv -- ./scripts/test
```

## Guix Packaging

Build and test as a standalone Guix package:

```bash
guix build -f guix.scm
```

## License

LGPL-3.0-or-later — see [LICENSE](LICENSE).
