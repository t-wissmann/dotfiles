 (require 'evil)
 (evil-mode 1)
(load-file "/usr/share/emacs/site-lisp/ProofGeneral/generic/proof-site.el")
(add-hook 'coq-mode-hook (lambda () (local-set-key (kbd "C-c RET") 'proof-goto-point)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 ;;'(coq-one-command-per-line nil)
 ;;'(proof-electric-terminator-enable t)
; '(proof-three-window-mode-policy (quote hybrid)))
)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;(add-to-list 'custom-theme-load-path "~/.emacs.d/color-theme/themes/")
;(load-theme 'zenburn t)
;;(require 'color-theme-zenburn)
;;(color-theme-zenburn)
(setq scroll-step 1)
