;;; -*- lexical-binding: t -*-

;; Enable mouse interaction
(require 'xt-mouse)
(xterm-mouse-mode)

;; Scroll like vim
(setq scroll-margin 10
      scroll-conservatively 10000
      scroll-step 1)

;; Indent with spaces rather than tabs by default
(setq-default indent-tabs-mode nil)

;; Appearance
(blink-cursor-mode 0)
(set-fringe-mode 0)
(global-linum-mode t)
(show-paren-mode 1)
(setq inhibit-startup-message t)
(setq initial-scratch-message
      (format ";;
;;
;; Yo, welcome dude. 
;;
;;
"
              emacs-version))

;; Padding for linum
(defun linum-format-func (line)
  (let ((w (length (number-to-string (count-lines (point-min) (point-max))))))
    (propertize (format (format "%%%dd " w) line) 'face 'linum)))
(setq linum-format 'linum-format-func)

;; Make the dividing line uniform
(set-face-background 'vertical-border "#484848")
(set-face-foreground 'vertical-border (face-background 'vertical-border))

(provide 'init-misc-configs)
