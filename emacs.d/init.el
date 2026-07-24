;;; init.el --- personal Emacs config (post-Doom) -*- lexical-binding: t; -*-

;;; Package bootstrap ---------------------------------------------------------

(require 'package)
; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-archives
      '(("gnu"    . "https://www.mirrorservice.org/sites/elpa.gnu.org/packages/")
        ("nongnu" . "https://www.mirrorservice.org/sites/elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://www.mirrorservice.org/sites/melpa.org/packages/")))

;; The machinery (package activation, `configure-packages', package install,
;; per-frame DPI font sizing) lives in vimacs.el.  Loading it activates the
;; installed packages, so this must precede the package configuration below.
(load (expand-file-name "vimacs.el" user-emacs-directory))

;; Declare, configure, and (via `my/install-packages') install each package.
;; Each :NAME is a package; the following lambda is its config function, run
;; on startup when the package is installed.  All package-specific setup lives
;; inside the respective function.
(configure-packages
   :evil
   (lambda ()
     (setq evil-want-keybinding nil)    ; play nicely with other modes
     (require 'evil)
     (evil-mode 1)

     ;; Move by visual lines.
     (dolist (map (list evil-normal-state-map
                        evil-visual-state-map
                        evil-motion-state-map))
       (define-key map (kbd "j") #'evil-next-visual-line)
       (define-key map (kbd "k") #'evil-previous-visual-line))

     ;; Cursor: shape + colour per state (colour must go through evil,
     ;; not the `cursor' face).
     (setq evil-normal-state-cursor   '(box       "#ff9900")
           evil-insert-state-cursor   '((bar . 2) "#ff9900")
           evil-visual-state-cursor   '(hollow    "#ff9900")
           evil-replace-state-cursor  '(hbar      "#ff9900")
           evil-operator-state-cursor '(hbar      "#ff9900")
           evil-motion-state-cursor   '(box       "#ff9900")
           evil-emacs-state-cursor    '(bar       "#ff9900")))

   :gruvbox-theme
   (lambda ()
     (load-theme 'gruvbox t)
     ;; Overrides layered on top of the theme.
     ;; On a graphical frame use the solid background; on a TTY keep the
     ;; background unspecified so the terminal's transparency shows through
     ;; (otherwise loading the theme re-opacifies the frame until
     ;; `my/unspecify-tty-background' runs at `window-setup-hook').
     (custom-set-faces
      '(line-number ((t (:inherit default :background "black" :foreground "#928374"))))
      '(line-number-current-line ((t (:inherit line-number :background "#3c3836"))))
      '(hl-line     ((t (:background "#3c3836"))))
      '(default     ((((type graphic)) (:background "#181818" :foreground "#EBDBB2"))
                     (t                (:background "unspecified-bg" :foreground "#EBDBB2"))))))

   :general
   (lambda ()
     ;; SPC leader in normal/visual/motion states, Doom-style.  The which-key
     ;; popup (see :which-key) labels each prefix as you type.
     (require 'general)
     (general-create-definer my/leader
       :states  '(normal visual motion)
       :keymaps 'override
       :prefix  "SPC")
     (my/leader
       "SPC" '(execute-extended-command :which-key "M-x")
       ":"   '(execute-extended-command :which-key "M-x")

       "f"   '(:ignore t :which-key "file")
       "f f" '(find-file            :which-key "find file")
       "f s" '(save-buffer          :which-key "save")
       "f S" '(write-file           :which-key "save as")

       "b"   '(:ignore t :which-key "buffer")
       "b b" '(switch-to-buffer     :which-key "switch")
       "b k" '(kill-current-buffer  :which-key "kill")
       "b n" '(next-buffer          :which-key "next")
       "b p" '(previous-buffer      :which-key "previous")
       "b r" '(revert-buffer        :which-key "revert")

       "w"   '(:ignore t :which-key "window")
       "w v" '(split-window-right   :which-key "split right")
       "w s" '(split-window-below   :which-key "split below")
       "w d" '(delete-window        :which-key "delete")
       "w o" '(delete-other-windows :which-key "only")
       "w h" '(evil-window-left     :which-key "left")
       "w j" '(evil-window-down     :which-key "down")
       "w k" '(evil-window-up       :which-key "up")
       "w l" '(evil-window-right    :which-key "right")

       "g"   '(:ignore t :which-key "git")
       "g g" '(magit-status         :which-key "status")

       "h"   '(help-command         :which-key "help")

       "q"   '(:ignore t :which-key "quit")
       "q q" '(save-buffers-kill-terminal :which-key "quit emacs")))

   :vertico
   (lambda ()
     ;; Vertical completion menu — this is the Doom M-x behaviour: as you
     ;; type, matching commands are listed below the minibuffer.
     (vertico-mode 1)
     (setq vertico-cycle t))            ; wrap around at the ends of the list

   :orderless
   (lambda ()
     ;; Space-separated, order-independent matching (e.g. "M-x fi buf" finds
     ;; `find-file-other-buffer').  Keep the built-in styles as fallbacks.
     (setq completion-styles '(orderless basic)
           completion-category-overrides
           '((file (styles basic partial-completion)))))

   :marginalia
   (lambda ()
     ;; Annotations (docstrings, key bindings, …) to the right of each
     ;; candidate, as in Doom.
     (marginalia-mode 1))

   :which-key
   (lambda ()
     (which-key-mode 1))

   :magit
   (lambda ()
     (global-set-key (kbd "C-x g") #'magit-status)))

;;; Identity ------------------------------------------------------------------

(setq user-full-name "Thorsten Wißmann"
      user-mail-address "edu@thorsten-wissmann.de")

;;; Sane defaults -------------------------------------------------------------

(setq confirm-kill-processes nil        ; kill processes on exit without asking
      confirm-kill-emacs nil            ; exit without confirmation
      inhibit-startup-screen t
      ring-bell-function 'ignore)
;; Suppress the "For information about GNU Emacs ... type SPC h C-a." echo-area
;; message.  Neutering the function (rather than the login-name-guarded
;; `inhibit-startup-echo-area-message' variable) keeps this portable.
(fset 'display-startup-echo-area-message #'ignore)
(setq-default indent-tabs-mode nil)
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;;; Line numbers --------------------------------------------------------------

(setq display-line-numbers-type t)
(setq-default display-line-numbers-width 0        ; hug the actual digits
              display-line-numbers-grow-only t)   ; shrink back when possible
(global-display-line-numbers-mode 1)

(defun my/line-number-width-from-buffer ()
  "Reserve line-number columns to fit this buffer's total line count."
  (setq-local display-line-numbers-width
              (length (number-to-string (line-number-at-pos (point-max))))))
(add-hook 'display-line-numbers-mode-hook #'my/line-number-width-from-buffer)
(add-hook 'after-save-hook #'my/line-number-width-from-buffer)

;;; Cursorline (vim-like current-line highlight) ------------------------------

(global-hl-line-mode 1)

;;; Frame appearance ----------------------------------------------------------

(add-to-list 'default-frame-alist '(alpha-background . 93))

;; On a TTY, let the terminal's own background show through.
(defun my/unspecify-tty-background (&optional frame)
  (unless (display-graphic-p frame)
    (set-face-background 'default "unspecified-bg" frame)))
(add-hook 'window-setup-hook #'my/unspecify-tty-background)
(add-hook 'after-make-frame-functions #'my/unspecify-tty-background)

;;; Font: size chosen from display DPI (machinery in vimacs.el) ---------------

(set-conditional-font-size (lambda (dpi)
   (cond ((>= dpi 190) 18)              ; hidpi / retina
         ((>= dpi 140) 14)              ; medium-high
         (t            12))))           ; standard

;;; Agda input method everywhere ---------------------------------------------

;; Load agda-input.el shipped with the Agda binary (version-agnostic glob).
(let ((agda-input (car (last (file-expand-wildcards
                              "~/.local/share/agda/*/emacs-mode/agda-input.el")))))
  (when agda-input
    (add-to-list 'load-path (file-name-directory agda-input))
    (require 'agda-input)
    (add-hook 'evil-insert-state-entry-hook (lambda () (set-input-method "Agda")))
    (add-hook 'evil-insert-state-exit-hook  (lambda () (set-input-method nil)))))

;;; init.el ends here
