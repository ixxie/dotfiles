;;; -*- lexical-binding: t -*-


(eval-when-compile
  (require 'use-package))
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

(use-package smartparens
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  :diminish smartparens-mode)

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

(require 'style)
(require 'tabs)
(require 'lang-tools)

(provide 'packages)
