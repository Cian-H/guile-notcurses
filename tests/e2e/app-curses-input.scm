;;; tests/e2e/app-curses-input.scm — Interactive (notcurses compat curses) app for tui-test.

(use-modules (notcurses compat curses))

(let ((win (initscr)))
  (move win 0 0)
  (addstr win "CURSES_READY")
  (refresh win)
  (let loop ()
    (let ((ch (getch win)))
      (cond
        ((= ch ERR) (loop))
        ((= ch (char->integer #\q))
         (endwin))
        ((= ch (char->integer #\b))
         (beep)
         (move win 1 0)
         (addstr win "BELL_SENT")
         (refresh win)
         (loop))
        (else
         (move win 1 0)
         (addstr win (format #f "GOT:~a   " ch))
         (refresh win)
         (loop))))))
