;;; init.el -- emacs meets vim

;; Turn these off before anything else to avoid momentary ugly flash
(scroll-bar-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)

;; Enable repos
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
  (add-to-list 'package-archives (cons "melpa" url) t))
(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

;; Define and install packages
(defvar my-packages '(evil
                      clojure-mode
                      haskell-mode
                      rust-mode
                      intero
                      base16-theme
                      telephone-line))
(dolist (p my-packages)
  (unless (package-installed-p p)
    (package-install p)))

(load-theme 'base16-eighties t)

(require 'evil)
(evil-mode 1)

(add-hook 'haskell-mode-hook 'intero-mode)

;; Define telephone line
(setq telephone-line-lhs
      '((evil   . (telephone-line-evil-tag-segment))
	(accent . (telephone-line-vc-segment
		   telephone-line-erc-modified-channels-segment
		   telephone-line-process-segment))
	(nil    . (telephone-line-minor-mode-segment
		   telephone-line-buffer-segment))))
(setq telephone-line-rhs
      '((nil    . (telephone-line-misc-info-segment))
	(accent . (telephone-line-major-mode-segment))
	(evil   . (telephone-line-airline-position-segment))))

;; Customize telephone line's faces to better match base16-eighties
(custom-theme-set-faces 'base16-eighties '(mode-line
                                           ((t (:foreground "#f99157" :background "#515151")))))
(custom-theme-set-faces 'base16-eighties '(telephone-line-accent-active
                                           ((t (:foreground "#f99157" :background "#393939" :inherit mode-line)))))
(custom-theme-set-faces 'base16-eighties '(telephone-line-accent-inactive
                                           ((t (:foreground "#000000" :background "#747369" :inherit mode-line-inactive)))))
(custom-theme-set-faces 'base16-eighties '(telephone-line-evil
                                           ((t (:foreground "#2d2d2d" :weight bold :inherit mode-line)))))
(custom-theme-set-faces 'base16-eighties '(telephone-line-evil-insert
                                           ((t (:background "#6699cc" :inherit telephone-line-evil)))))
(custom-theme-set-faces 'base16-eighties '(telephone-line-evil-normal
                                           ((t (:background "#99cc99" :inherit telephone-line-evil)))))
(custom-theme-set-faces 'base16-eighties '(telephone-line-evil-visual
                                           ((t (:background "#cc99cc" :inherit telephone-line-evil)))))
(custom-theme-set-faces 'base16-eighties '(telephone-line-evil-replace
                                           ((t (:background "#e8e6df" :inherit telephone-line-evil)))))
(custom-theme-set-faces 'base16-eighties '(telephone-line-evil-motion
                                           ((t (:background "#f2777a" :inherit telephone-line-evil)))))
(custom-theme-set-faces 'base16-eighties '(telephone-line-evil-operator
                                           ((t (:background "#ffcc66" :inherit telephone-line-evil)))))
(custom-theme-set-faces 'base16-eighties '(telephone-line-evil-emacs
                                           ((t (:background "#66cccc" :inherit telephone-line-evil)))))

(require 'telephone-line)
(telephone-line-mode t)

;; Scroll like vim
(setq scroll-margin 10
      scroll-conservatively 0
      scroll-step 1)

;; Indent with spaces rather than tabs by default
(setq-default indent-tabs-mode nil)

;; Appearance
(blink-cursor-mode 0)
(set-fringe-mode 0)
(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(global-linum-mode t)

;; Padding for linum
(defun linum-format-func (line)
  (let ((w (length (number-to-string (count-lines (point-min) (point-max))))))
    (propertize (format (format "%%%dd " w) line) 'face 'linum)))
(setq linum-format 'linum-format-func)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (telephone-line base16-theme rust-mode haskell-mode clojure-mode evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
