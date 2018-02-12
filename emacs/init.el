;;; -*- lexical-binding: t -*-

;; Set garbage collection
(setq gc-cons-threshold (* 128 1024 1024))
(add-hook 'after-init-hook
          (lambda () (setq gc-cons-threshold (* 20 1024 1024))))

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Path to user directory
(add-to-list 'load-path (expand-file-name "init" user-emacs-directory))

;; Load configurations
(require 'packages)
(require 'misc-config)
