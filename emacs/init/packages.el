;;; -*- lexical-binding: t -*-

(eval-when-compile
  (require 'use-package))

(package-initialize)

(require 'bind-key)
(require 'diminish)

;; Packages
(use-package evil
  :config
  (evil-mode 1))

(use-package base16-theme
  :config
  (load-theme 'base16-eighties t))

(use-package multi-term)

(use-package neotree
  :bind ("M-q" . neotree-toggle))

(use-package which-key
  :demand t
  :config
  (which-key-mode)
  :commands (which-key-show-top-level)
  :bind ("C-+" . which-key-show-top-level)
  :diminish which-key-mode)

(use-package rainbow-mode
  :defer t
  :commands (rainbow-mode))

(use-package projectile
  :config
  (projectile-mode))

(require 'lang-tools)
(require 'style)
(require 'tabs)

(provide 'packages)
