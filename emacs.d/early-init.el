;;; early-init.el --- loaded before the GUI and package system -*- lexical-binding: t; -*-

;; Keep the GC out of the way while starting up; back to something sane after.
(setq gc-cons-threshold (* 128 1024 1024)
      gc-cons-percentage 0.6)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 32 1024 1024)
                  gc-cons-percentage 0.1)))

(setq frame-inhibit-implied-resize t
      inhibit-startup-screen t
      initial-scratch-message nil
      inhibit-x-resources t
      package-quickstart t)

;; Log native-compilation warnings instead of popping the *Warnings* buffer.
;; Silences upstream false positives (e.g. general.el's `general-normalize-hook'
;; defined inside a `with-eval-after-load' block) without hiding real errors.
(setq native-comp-async-report-warnings-errors 'silent)

;; Set the chrome via `default-frame-alist' rather than the modes, so it is
;; never drawn in the first place (no flicker, slightly faster startup).
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(alpha-background . 93) default-frame-alist)
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

;; Same colours the theme ends up with, so there is no white flash before
;; init.el has loaded it.  Only on a graphical display, though: on a TTY a
;; solid background defeats the terminal's transparency (and shows up as a
;; brief opaque flash at startup), so let the terminal's own background show.
(when initial-window-system
  (push '(background-color . "#181818") default-frame-alist)
  (push '(foreground-color . "#EBDBB2") default-frame-alist))

;;; early-init.el ends here
