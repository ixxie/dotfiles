;;; -*- lexical-binding: t -*-

;; Path of locked packages
(let ((default-directory "~/.emacs.d/locked-packages"))
  (normal-top-level-add-to-load-path '("use-package"
                                       "diminish")))

;; Pin packages
(setq package-pinned-packages '((evil . "melpa-stable") ; Dependencies will be fetched from MELPA
                                (clojure-mode . "melpa-stable")
                                (haskell-mode . "melpa-stable")
                                (rust-mode . "melpa-stable")
                                (base16-theme . "melpa-stable")
                                (telephone-line . "melpa-stable")
                                (rainbow-delimiters . "melpa-stable")
                                (smartparens . "melpa-stable")
                                (cider . "melpa-stable")
                                (cargo . "melpa-stable")
                                (which-key . "melpa-stable")
                                (flycheck . "melpa-stable")

                                (flycheck-rust . "melpa")

                                (rainbow-mode . "elpa")))

(eval-when-compile
  (require 'use-package))
(require 'bind-key)
(require 'diminish)

(use-package evil
  :ensure t
  :config (evil-mode 1))

(use-package base16-theme
  :ensure t
  :config (load-theme 'base16-eighties t))

(use-package smartparens
  :ensure t
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  :diminish smartparens-mode)

(use-package which-key
  :ensure t
  :demand t
  :config (which-key-mode)
  :commands (which-key-show-top-level)
  :bind ("C-+" . which-key-show-top-level)
  :diminish which-key-mode)

(require 'init-telephone-line)
(require 'init-lang)

(provide 'init-packages)
