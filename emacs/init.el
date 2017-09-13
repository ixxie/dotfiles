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

;; Path to user directory
(add-to-list 'load-path (expand-file-name "user" user-emacs-directory))

;; Load configurations
(require 'init-packages)
(require 'init-misc-configs)

