;;; other emacs lisp snippets not yet used:


;;; Spell checking -------------------------------------------------------------

;; aspell rather than the plain `ispell' binary: better suggestions, and its
;; dictionaries cover German (apt install aspell aspell-de aspell-en).
(setq ispell-program-name (or (executable-find "aspell") "ispell"))
;; `--sug-mode' is aspell-only -- the plain ispell binary rejects it and dies.
(when (string-suffix-p "aspell" ispell-program-name)
  (setq ispell-extra-args '("--sug-mode=ultra")))  ; fast suggestion engine

(defvar my/spell-states '(nil "de_DE" "en_US")
  "States cycled through by `my/spell-cycle'.
nil means no spell checking, a string is the dictionary to check with.")

(defun my/spell-cycle ()
  "Cycle spell checking for this buffer: off -> German -> English -> off."
  (interactive)
  ;; The current state is the dictionary in use, or nil while flyspell is off --
  ;; `ispell-local-dictionary' keeps its value when the mode is switched off.
  (let* ((current (and (bound-and-true-p flyspell-mode)
                       (bound-and-true-p ispell-local-dictionary)))
         ;; One step along the list, wrapping around at its end.
         (next (or (cadr (member current my/spell-states))
                   (car my/spell-states))))
    (if (null next)
        (progn (flyspell-mode -1)
               (message "Spell checking off"))
      ;; Not a plain `setq': changing the dictionary has to kill the running
      ;; ispell process, otherwise it keeps checking against the old language.
      (ispell-change-dictionary next)
      ;; In code, check comments and strings only; elsewhere check everything.
      (if (derived-mode-p 'prog-mode)
          (flyspell-prog-mode)
        (flyspell-mode 1))
      (flyspell-buffer)
      (message "Spell checking: %s" next))))

(global-set-key (kbd "<f7>") #'my/spell-cycle)
