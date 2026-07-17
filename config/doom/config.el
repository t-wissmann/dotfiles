;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; vim: ts=2 sw=2

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Thorsten Wißmann"
      user-mail-address "edu@thorsten-wissmann.de")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-one)
;; (setq doom-theme 'doom-gruvbox)
;; -> M-x load-theme! or SPC h t
(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
(setq-default display-line-numbers-width 0       ; no minimum width — hug the actual digits
              display-line-numbers-grow-only t)  ; allow shrinking back when numbers get shorter

;; adjust width of line numbers depending on buffer length:
(defun my/line-number-width-from-buffer ()
  "Reserve line-number columns to fit this buffer's total line count."
  (setq-local display-line-numbers-width
              (length (number-to-string (line-number-at-pos (point-max))))))

(add-hook 'display-line-numbers-mode-hook #'my/line-number-width-from-buffer)
(add-hook 'after-save-hook #'my/line-number-width-from-buffer)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;;(set-face-attribute
;;    proof-colour-locked :height
;;    )
;;(after! proof-general
;;)

;; ;; the following only makes sense on dark backrounds
;;     (custom-set-faces
;;      ;;'(proof-queue-face
;;      ;;  ((t :weight bold)))
;;      ;;'(proof-locked-face
;;      ;;  ((t :weight bold)))
;;      '(proof-queue-face
;;        ((t :weight bold)))
;;      '(proof-locked-face
;;        ((t (:background "#1F2912")
;;            )))
;;      '(proof-tactics-name-face
;;        ((t (:foreground "#9DDAA1")
;;            )))
;;      )
(custom-theme-set-faces! 'doom-gruvbox
  '(line-number :inherit default
                  :background "black"
               :foreground "#928374"
                  )
  '(default :background "#181818"
              :foreground "#EBDBB2"
              )
  ;; '(fringe :background "black")
  '(cursor :background "#ff9900")
  )

;; (set-fontset-font "fontset-default" nil
;;    (font-spec :name "Bitstream Vera Sans Mono" :size 8)
;;    )

(defun my/display-dpi (&optional frame)
  "Return the DPI of FRAME's display, or nil if unknown."
  (let* ((attrs (car (display-monitor-attributes-list frame)))
         (mm    (alist-get 'mm-size attrs))
         (geom  (alist-get 'geometry attrs)))
    (when (and mm geom (> (car mm) 0))
      (/ (float (nth 2 geom))          ; width in pixels
         (/ (car mm) 25.4)))))         ; width in inches

(defun my/font-size-for-dpi (&optional frame)
  "Pick a font point size based on FRAME's display DPI."
  (let ((dpi (or (my/display-dpi frame) 96)))
    (cond ((>= dpi 190) 14)   ; hidpi / retina
          ((>= dpi 140) 13)   ; medium-high
          (t            12)))) ; standard

;; Set the font per-frame: as a daemon, config.el runs with no graphical
;; frame, so DPI can only be read once a real frame exists.
(defun my/set-font-for-frame (&optional frame)
  (when (display-graphic-p frame)
    (setq doom-font (font-spec :name "Bitstream Vera Sans Mono"
                               :size (my/font-size-for-dpi frame)))
    (when (fboundp 'doom/reload-font)
      (doom/reload-font))))

(add-hook 'after-make-frame-functions #'my/set-font-for-frame)
;; Also handle the non-daemon case, where a frame already exists at startup.
(add-hook 'window-setup-hook #'my/set-font-for-frame)


(after! unicode-fonts
  (dolist (unicode-block '("Mathematical Alphanumeric Symbols"
			   "Mathematical Operators"
			   "Miscellaneous Mathematical Symbols-A"
			   "Miscellaneous Mathematical Symbols-B"
			   "Letterlike Symbols" ;; for ℰ
			   "Miscellaneous Symbols"
			   "Miscellaneous Symbols and Arrows"
			   "Miscellaneous Symbols and Pictographs"))
      (push "DejaVu Math TeX Gyre" (cadr (assoc unicode-block unicode-fonts-block-font-mapping)))))


;; (after! core-ui (menu-bar-mode 1))
(map! :map evil-window-map
      "z" #'doom/window-zoom)
(map! :nvm "j" #'evil-next-visual-line
      :nvm "k" #'evil-previous-visual-line)
;; kill processes on exit without asking
(setq confirm-kill-processes nil)
;; exit emacs without confirmation
(setq confirm-kill-emacs nil)


(setq doom-localleader-key ",")
;; Also use SPC m for localleader
(defun my/call-localleader ()
  (interactive)
  (setq unread-command-events (listify-key-sequence ",")))

(map! :leader (:desc "localleader" "m" #'my/call-localleader))

;; Agda-input mode everywhere!
;; https://emacs.stackexchange.com/a/27023/16063
(add-hook 'evil-insert-state-entry-hook (lambda () (set-input-method "Agda")))
(add-hook 'evil-insert-state-exit-hook (lambda () (set-input-method nil)))

(add-to-list 'default-frame-alist '(alpha-background . 93))

(defun on-after-init (&optional frame)
  (unless (display-graphic-p frame)
    (set-face-background 'default "unspecified-bg" frame)))

;; (unless (display-graphic-p (selected-frame))
;;   (menu-bar-mode -1))
;; (xterm-mouse-mode 1)
(menu-bar-mode -1)
;; (vi-tilde-fringe-mode -1)

;;(add-hook 'after-make-frame-functions 'on-frame-open)
(add-hook 'window-setup-hook 'on-after-init)

(defun agda2-normalized-goal-and-context-and-inferred ()
  (interactive)
  (agda2-goal-and-context-and-inferred '(3)))
(eval-after-load "agda2-mode"
  '(progn
   (define-key agda2-mode-map (kbd "C-c C-,")
      'agda2-normalized-goal-and-context)
   (define-key agda2-mode-map (kbd "C-c C-.")
      'agda2-normalized-goal-and-context-and-inferred)
   (define-key agda2-mode-map (kbd "C-.")
      'agda2-goto-definition-keyboard)
   (map! :map agda2-mode-map
         :localleader
         ;; :prefix "l"
         ">" 'agda2-goto-definition-keyboard
         ;; "m" #'lorem-function
         )
  ))

(after! evil
  (setq evil-normal-state-cursor   '(box      "#ff9900")
        evil-insert-state-cursor   '((bar . 2) "#ff9900")
        evil-visual-state-cursor   '(hollow   "#ff9900")
        evil-replace-state-cursor  '(hbar     "#ff9900")
        evil-operator-state-cursor '(hbar     "#ff9900")
        evil-motion-state-cursor   '(box      "#ff9900")
        evil-emacs-state-cursor    '(bar      "#ff9900")))





;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
