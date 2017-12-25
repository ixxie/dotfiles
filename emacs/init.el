;;; -*- lexical-binding: t -*-

;;; init.el -- emacs meets vim

;; Set garbage collection
(setq gc-cons-threshold (* 128 1024 1024))
(add-hook 'after-init-hook
          (lambda () (setq gc-cons-threshold (* 20 1024 1024))))

;; Path to user directory
(add-to-list 'load-path (expand-file-name "init" user-emacs-directory))

;; Load configurations
(require 'packages)
(require 'misc-config)
