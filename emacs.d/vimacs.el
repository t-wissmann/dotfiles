;;; vimacs.el --- package install/configure helpers -*- lexical-binding: t; -*-

;;; Commentary:
;; Helper functions used by init.el to declare, install, and configure
;; packages: `a-list' builds the (PACKAGE . CONFIG-FUNCTION) alist,
;; `my/install-packages' installs/updates them, and
;; `my/configure-packages' runs each config function.

;;; Code:

(require 'cl-lib)
(require 'package)

;; Defined in init.el; used by the install/configure helpers below.
(defvar my/packages)

(defun a-list (&rest pairs)
  "Build an alist from alternating KEYWORD FUNCTION arguments.
Each :NAME keyword becomes the symbol NAME in the car of the cell."
  (let (result)
    (while pairs
      (let ((key (pop pairs))
            (fn  (pop pairs)))
        (push (cons (intern (substring (symbol-name key) 1)) fn) result)))
    (nreverse result)))

(defun my/install-packages ()
  "Install or update every package in `my/packages'.
Progress is shown in a dedicated buffer.  Run this manually via
\\[my/install-packages]; it is not called on startup."
  (interactive)
  (let* ((buffer (get-buffer-create "*my-package-install*"))
         (out (lambda (fmt &rest args)
                (with-current-buffer buffer
                  (goto-char (point-max))
                  (let ((inhibit-read-only t))
                    (insert (apply #'format fmt args) "\n")))
                (redisplay t)))
         ;; Mirror package.el's own `message' output into the buffer.
         (relay (lambda (orig fmt &rest args)
                  (when fmt (ignore-errors (apply out fmt args)))
                  (apply orig fmt args))))
    (with-current-buffer buffer
      (setq buffer-read-only nil)
      (erase-buffer))
    ;; Show the buffer *before* doing the work so progress is visible live.
    (pop-to-buffer buffer)
    (advice-add 'message :around relay)
    (unwind-protect
        (progn
          (funcall out "Refreshing package archives...")
          (package-refresh-contents)
          (dolist (cell my/packages)
            (let ((pkg (car cell)))
              (funcall out "== %s ==" pkg)
              (condition-case err
                  (if (package-installed-p pkg)
                      (package-upgrade pkg)
                    (package-install pkg))
                (error (funcall out "  %s: %s" pkg (error-message-string err))))))
          ;; Rebuild the quickstart file so the next startup uses the fast path.
          (funcall out "Refreshing package-quickstart...")
          (package-quickstart-refresh))
      (advice-remove 'message relay))
    (funcall out "Finished.")))

(defun my/configure-packages ()
  "Run each config function from `my/packages' whose package is installed."
  (dolist (cell my/packages)
    (when (package-installed-p (car cell))
      (funcall (cdr cell)))))

(provide 'vimacs)
;;; vimacs.el ends here
