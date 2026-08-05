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
     (setq evil-want-C-u-scroll t)      ; C-u scrolls up (SPC u for prefix arg)
     ;; (setq evil-want-minibuffer t) ; breaks screen update on ':' and 'M-x'
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
           evil-emacs-state-cursor    '(bar       "#ff9900"))

     (add-hook 'evil-insert-state-entry-hook (lambda () (send-string-to-terminal "\033[5 q")))
     (add-hook 'evil-insert-state-exit-hook  (lambda () (send-string-to-terminal "\033[2 q"))))

   :evil-collection
   (lambda ()
     ;; Evil (hjkl &c.) bindings inside magit's status/log buffers and its
     ;; transient popup menus.  Depends on `evil-want-keybinding' nil, set
     ;; under :evil above, which is why :evil is declared first.
     (require 'evil-collection)
     (evil-collection-init '(magit)))

   :doom-themes
   (lambda ()
     (load-theme 'doom-gruvbox t)
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
       "u"   '(universal-argument       :which-key "universal arg")

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
     (global-set-key (kbd "C-x g") #'magit-status))

   :markdown-mode
   (lambda ()
     ;; Lazy: this config function runs at startup, but only registers the
     ;; file-extension mappings onto the *autoloaded* `markdown-mode' /
     ;; `gfm-mode'.  markdown-mode.el itself is pulled in only when the first
     ;; Markdown file is opened (like the Agda block above).
     (add-to-list 'auto-mode-alist '("\\.md\\'"       . markdown-mode))
     (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
     ;; README.md gets GitHub-Flavoured Markdown (added last, so it takes
     ;; precedence over the \.md\' entry above).
     (add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))
     ;; Syntax-highlight fenced code blocks in their source language.
     (setq markdown-fontify-code-blocks-natively t))

   :unicode-fonts
   (lambda ()
     ;; Render math (and a few symbol) Unicode blocks with DejaVu Math TeX
     ;; Gyre in preference to whatever else covers them.  `push' onto the
     ;; front of each block's font list makes DejaVu the first choice; this
     ;; must happen before `unicode-fonts-setup' builds the fontsets.
     (require 'unicode-fonts)
     (dolist (unicode-block '("Mathematical Alphanumeric Symbols"
                              "Mathematical Operators"
                              "Miscellaneous Mathematical Symbols-A"
                              "Miscellaneous Mathematical Symbols-B"
                              "Letterlike Symbols" ; for ℰ
                              "Miscellaneous Symbols"
                              "Miscellaneous Symbols and Arrows"
                              "Miscellaneous Symbols and Pictographs"))
       (push "DejaVu Math TeX Gyre"
             (cadr (assoc unicode-block unicode-fonts-block-font-mapping))))
     (unicode-fonts-setup)))

;;; Identity ------------------------------------------------------------------

(setq user-full-name "Thorsten Wißmann"
      user-mail-address "edu@thorsten-wissmann.de")

;;; Sane defaults -------------------------------------------------------------

(setq confirm-kill-processes nil        ; kill processes on exit without asking
      confirm-kill-emacs nil            ; exit without confirmation
      inhibit-startup-screen t
      ring-bell-function 'ignore)

(setq-default mode-line-end-spaces nil)
;; Suppress the "For information about GNU Emacs ... type SPC h C-a." echo-area
;; message.  Neutering the function (rather than the login-name-guarded
;; `inhibit-startup-echo-area-message' variable) keeps this portable.
(fset 'display-startup-echo-area-message #'ignore)
(setq-default indent-tabs-mode nil)

;; Emacs keeps a buffer's auto-save file (#name#) around when it is killed
;; unsaved, so exiting via `:qa!' leaves recovery files behind.  Delete every
;; buffer's auto-save file on exit so a forced quit cleans up after itself.
(defun my/delete-all-auto-save-files ()
  "Delete the auto-save file of every live buffer."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (delete-auto-save-file-if-necessary t))))
(add-hook 'kill-emacs-hook #'my/delete-all-auto-save-files)
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

;; No line-number bar in the Agda info window (*Agda information*, which uses
;; `compilation-mode').  The global minor mode would otherwise turn it on there.
(add-hook 'compilation-mode-hook
          (lambda ()
            (when (equal (buffer-name) "*Agda information*")
              (display-line-numbers-mode -1))))

;;; Cursorline (vim-like current-line highlight) ------------------------------

(setq global-hl-line-sticky-flag t)     ; highlight in every window, not just the focused one
(global-hl-line-mode 1)

;;; Mode line: position --------------------------------------------------------

;; Column next to the line number, so the position reads "(LINE,COLUMN)".
;; Counted from 1 like vim's ruler, rather than Emacs' 0-based default.
(setq column-number-indicator-zero-based nil)
(column-number-mode 1)

;;; Mode line / window title: buffer path -------------------------------------

;; Machinery in vimacs.el: the project-relative path replaces the stock bare
;; `%12b' buffer name in the mode line (dirname dimmed, file name bright) and
;; becomes the window title, terminal frames included.
;;
;; Each colour is given as (TRUECOLOR COLOR256 FALLBACK), one per display
;; depth.  Letting Emacs approximate the hex itself is what turns the
;; mode-line background olive-green inside tmux -- see `my/colour-depth-spec'.
(set-buffer-path-mode-line
 :dir                 '("#928374" "color-245" "brightblack")
 :file                '("#fabd2f" "color-214" "yellow")
 :background          '("#37302f" "color-236" "black")
 :inactive-background '("#282828" "color-234" "black"))

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

;;; Agda mode ----------------------------------------------------------------

;; The Emacs files ship with the Agda binary, not ELPA (version-agnostic glob
;; finds the emacs-mode directory).  Two things live there:
;;   agda-input.el  the "Agda" input method (\\alpha -> α &c.)
;;   agda2.el       a tiny stub that `autoload's `agda2-mode' and maps it onto
;;                  \\.l?agda\\' in `auto-mode-alist'.  Loading it is cheap; the
;;                  heavy agda2-mode.el is pulled in lazily only when the first
;; ;;                  .agda file is opened.
;; (let ((agda-input (car (last (file-expand-wildcards
;;                               "~/.local/share/agda/*/emacs-mode/agda-input.el")))))
;;   (when agda-input
;;     (add-to-list 'load-path (file-name-directory agda-input))
;;     ;; Agda input method available everywhere, in evil insert state.
;;     (require 'agda-input)
;;     (add-hook 'evil-insert-state-entry-hook (lambda () (set-input-method "Agda")))
;;     (add-hook 'evil-insert-state-exit-hook  (lambda () (set-input-method nil)))
;;     ))

;; Local-leader keybindings for Agda, under `,' and `SPC m' (Doom-style).
;; Deferred until agda2-mode.el actually loads (first .agda file), so the
;; heavy mode stays lazy; `general' is already required by the :general block.
;;   `,'   is bound in `agda2-mode-map' (buffer-local; the override leader
;;         map does not capture `,', so it reaches the buffer).
;;   `SPC m' is bound in the override leader map, because a buffer-local
;;         `SPC' binding would be shadowed by it; a `:predicate' restricts it
;;         to Agda buffers so the prefix falls through everywhere else.
(with-eval-after-load 'agda2-mode
  (let ((keys
         (list
          ""    '(:ignore t                                  :which-key "agda")
          "l"   '(agda2-load                                 :which-key "load")
          "r"   '(agda2-refine                               :which-key "refine")
          "SPC" '(agda2-give                                 :which-key "give")
          "c"   '(agda2-make-case                            :which-key "case")
          "a"   '(agda2-mimer-maybe-all                      :which-key "auto")
          "t"   '(agda2-goal-type                            :which-key "goal type")
          "e"   '(agda2-show-context                         :which-key "context")
          "d"   '(agda2-infer-type-maybe-toplevel            :which-key "infer type")
          "n"   '(agda2-compute-normalised-maybe-toplevel    :which-key "normalise")
          ","   '(agda2-goal-and-context                     :which-key "goal + context")
          "."   '(agda2-goal-and-context-and-inferred        :which-key "goal + inferred")
          ";"   '(agda2-goal-and-context-and-checked         :which-key "goal + checked")
          "s"   '(agda2-solve-maybe-all                      :which-key "solve constraints")
          "w"   '(agda2-why-in-scope-maybe-toplevel          :which-key "why in scope")
          "o"   '(agda2-module-contents-maybe-toplevel       :which-key "module contents")
          "z"   '(agda2-search-about-toplevel                :which-key "search about")
          "h"   '(agda2-helper-function-type                 :which-key "helper type")
          "f"   '(agda2-next-goal                            :which-key "next goal")
          "b"   '(agda2-previous-goal                        :which-key "prev goal")
          "?"   '(agda2-show-goals                           :which-key "show goals")
          "="   '(agda2-show-constraints                     :which-key "show constraints")
          "g"   '(agda2-goto-definition-keyboard             :which-key "goto definition")
          "x"   '(:ignore t                                  :which-key "system")
          "x c" '(agda2-compile                              :which-key "compile")
          "x r" '(agda2-restart                              :which-key "restart")
          "x q" '(agda2-quit                                 :which-key "quit")
          "x a" '(agda2-abort                                :which-key "abort")
          "x d" '(agda2-remove-annotations                   :which-key "deactivate")
          "x h" '(agda2-display-implicit-arguments           :which-key "toggle implicit")
          "x i" '(agda2-display-irrelevant-arguments         :which-key "toggle irrelevant"))))
    (apply #'general-define-key
           :states '(normal visual motion) :keymaps 'agda2-mode-map
           :prefix "," keys)
    (apply #'general-define-key
           :states '(normal visual motion) :keymaps 'override
           :prefix "SPC m" :predicate '(derived-mode-p 'agda2-mode) keys)))

;;; init.el ends here
;; (load (expand-file-name "setup-agda.el" user-emacs-directory))
(autoload 'agda2-mode (expand-file-name "setup-agda.el" user-emacs-directory)
          "agda2-mode (delayed)" t)
(add-to-list 'auto-mode-alist '("\\.agda\\'" . agda2-mode))
;; (load-file (let ((coding-system-for-read 'utf-8))
;;                 (shell-command-to-string "agda --emacs-mode locate")))

;; Advertise the "Agda" input method to `set-input-method' without loading
;; anything heavy -- the input-method analogue of the `agda2-mode' autoload
;; above.  `register-input-method' only adds "Agda" to `input-method-alist'
;; (so it tab-completes in `set-input-method' / `C-x RET C-\'); the
;; ACTIVATE-FUNC `quail-use-package' does not run until "Agda" is first
;; selected.  It then `load's its trailing library argument -- setup-agda.el
;; -- which `require's agda2-mode.el, which `require's agda-input.el, whose
;; `quail-define-package' defines the real "Agda" Quail package that
;; `quail-use-package' goes on to activate.  Same lazy file, same one-time
;; cost as opening the first .agda buffer.
(register-input-method
 "Agda" "UTF-8" #'quail-use-package "∏"
 "Agda input method (\\alpha -> α &c.); loads setup-agda.el on first use."
 (expand-file-name "setup-agda.el" user-emacs-directory))
