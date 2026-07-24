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

;;; Font: size chosen from display DPI, set per-frame -------------------------

(defun my/display-dpi (&optional frame)
  "Return the DPI of FRAME's display, or nil if unknown."
  (let* ((attrs (car (display-monitor-attributes-list frame)))
         (mm    (alist-get 'mm-size attrs))
         (geom  (alist-get 'geometry attrs)))
    (when (and mm geom (> (car mm) 0))
      (/ (float (nth 2 geom))            ; width in pixels
         (/ (car mm) 25.4)))))           ; width in inches

(defvar my/font-size-function (lambda (_dpi) 12)
  "Function mapping a display DPI to a font point size.
Set it with `set-conditional-font-size'.")

(defun set-conditional-font-size (fn)
  "Use FN to choose the font point size from a display DPI.
FN is called with one argument, the DPI, and returns a point size."
  (setq my/font-size-function fn))

(defun my/font-size-for-dpi (&optional frame)
  "Pick a font point size based on FRAME's display DPI."
  (funcall my/font-size-function (or (my/display-dpi frame) 96)))

(defun my/set-font-for-frame (&optional frame)
  "Set the frame font once a graphical FRAME exists (needed under daemon)."
  (when (display-graphic-p frame)
    (set-frame-font (font-spec :name "Bitstream Vera Sans Mono"
                               :size (my/font-size-for-dpi frame))
                    nil (list frame))))
(add-hook 'after-make-frame-functions #'my/set-font-for-frame)
(add-hook 'window-setup-hook #'my/set-font-for-frame)

(provide 'vimacs)
;;; vimacs.el ends here
