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

;; Enable package and repos
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (url-smelpa (concat (if no-ssl "http" "https") "://stable.melpa.org/packages/"))
       (url-melpa (concat (if no-ssl "http" "https") "://melpa.org/packages/"))
       (url-elpa (concat (if no-ssl "http" "https") "://elpa.gnu.org/packages/")))
  (setq package-archives '()) ; This needs fixing
  (add-to-list 'package-archives (cons "melpa-stable" url-smelpa) t)
  (add-to-list 'package-archives (cons "melpa" url-melpa) t)
  (add-to-list 'package-archives (cons "elpa" url-elpa) t))
(package-initialize)

;; Load configurations
(require 'init-packages)
(require 'init-misc-configs)

