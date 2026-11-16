;;; tests/test-compat-curses.scm — Tests for (notcurses compat curses).

(use-modules (srfi srfi-64)
             (notcurses compat curses))

(test-begin "compat-curses")

(test-equal "ERR is -1" -1 ERR)
(test-equal "key-defined resolves Ctrl+Up/Down" KEY_FIND (key-defined "\x1b[1;5A"))
(test-equal "key-defined resolves Ctrl+Down" KEY_OPEN (key-defined "\x1b[1;5B"))
(test-equal "key-defined unknown returns #f" #f (key-defined "\x1b[99Z"))

(test-assert "init-pair! and color-pair"
  (and (init-pair! 1 COLOR_RED COLOR_BLACK)
       (= 1 (color-pair 1))))

(test-assert "nodelay! returns #t"
  (and (nodelay! #f #t)
       (nodelay #f #f)))

(test-equal "pushback-count starts at 0" 0 (pushback-count))
(test-equal "drain-mouse-events starts empty" '() (drain-mouse-events))
(test-equal "drain-input-burst! outside session returns empty" '() (drain-input-burst!))
(test-equal "input-pending? outside session returns #f" #f (input-pending?))

(test-end "compat-curses")
