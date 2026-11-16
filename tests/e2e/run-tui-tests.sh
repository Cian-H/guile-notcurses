#!/usr/bin/env bash
set -euo pipefail

E2E_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${E2E_DIR}/../.." && pwd)"
export GUILE_LOAD_PATH="${ROOT_DIR}${GUILE_LOAD_PATH:+:$GUILE_LOAD_PATH}"

S1="gnc-e2e-widgets-$$"
S2="gnc-e2e-curses-$$"

cleanup() {
    tui-test --session "$S1" close >/dev/null 2>&1 || true
    tui-test --session "$S2" close >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "=== E2E: input, mouse, resize, and widgets ==="
tui-test run --session "$S1" --cols 80 --rows 24 \
    --env "GUILE_LOAD_PATH=${GUILE_LOAD_PATH}" \
    --env "GUILE_AUTO_COMPILE=0" \
    -- guile --no-auto-compile "${E2E_DIR}/app-input-and-widgets.scm" >/dev/null

tui-test --session "$S1" expect text "READY" --timeout 5000 >/dev/null
tui-test --session "$S1" key press a >/dev/null
tui-test --session "$S1" expect text "KEY:a" --timeout 3000 >/dev/null

tui-test --session "$S1" key press Up >/dev/null
tui-test --session "$S1" expect text "KEY:UP" --timeout 3000 >/dev/null

tui-test --session "$S1" key press Ctrl+k >/dev/null
tui-test --session "$S1" expect text "KEY:CTRL+k" --timeout 3000 >/dev/null

tui-test --session "$S1" click text "CLICK_ME" >/dev/null
tui-test --session "$S1" expect text "MOUSE:1@2," --timeout 3000 >/dev/null

tui-test --session "$S1" resize 100 30 >/dev/null
tui-test --session "$S1" expect text "RESIZED:30x100" --timeout 3000 >/dev/null

tui-test --session "$S1" key press w >/dev/null
tui-test --session "$S1" expect text "SEL:beta" --timeout 3000 >/dev/null
tui-test --session "$S1" expect text "READER:hi" --timeout 3000 >/dev/null
tui-test --session "$S1" expect text "MENU:ok" --timeout 3000 >/dev/null

tui-test --session "$S1" key press q >/dev/null
tui-test --session "$S1" wait exit --timeout 3000 >/dev/null
tui-test --session "$S1" close >/dev/null
echo "  ok: input, mouse, resize, selector, reader, menu"

echo "=== E2E: compat/curses input and bell ==="
tui-test run --session "$S2" --cols 80 --rows 24 \
    --env "GUILE_LOAD_PATH=${GUILE_LOAD_PATH}" \
    --env "GUILE_AUTO_COMPILE=0" \
    -- guile --no-auto-compile "${E2E_DIR}/app-curses-input.scm" >/dev/null

tui-test --session "$S2" expect text "CURSES_READY" --timeout 5000 >/dev/null
tui-test --session "$S2" key press x >/dev/null
tui-test --session "$S2" expect text "GOT:120" --timeout 3000 >/dev/null

tui-test --session "$S2" key press b >/dev/null
tui-test --session "$S2" expect text "BELL_SENT" --timeout 3000 >/dev/null

tui-test --session "$S2" key press q >/dev/null
tui-test --session "$S2" wait exit --timeout 3000 >/dev/null
tui-test --session "$S2" close >/dev/null
echo "  ok: compat/curses getch and beep"
