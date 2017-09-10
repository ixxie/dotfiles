;;; -*- lexical-binding: t -*-

;;; init.el -- emacs meets vim

;; Turn these off early to avoid seeing them at all
(scroll-bar-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)

;; Set garbage collection
(setq gc-cons-threshold (* 128 1024 1024))
(add-hook 'after-init-hook
          (lambda () (setq gc-cons-threshold (* 20 1024 1024))))

;; Enable melpa and package
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
  (add-to-list 'package-archives (cons "melpa" url) t))
(package-initialize)

;; Path of locked packages
(let ((default-directory "~/.emacs.d/locked-packages"))
  (normal-top-level-add-to-load-path '("evil")))

;; Path to user directory
(add-to-list 'load-path (expand-file-name "user" user-emacs-directory))

;; Load configurations
(require 'init-packages)
(require 'init-misc-configs)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (rainbow-delimiters which-key telephone-line rust-mode rainbow-mode intero clojure-mode base16-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
