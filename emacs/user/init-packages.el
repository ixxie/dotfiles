;;; -*- lexical-binding: t -*-

;; Path for `use-package` and its dependency
(let ((default-directory "~/.emacs.d/locked-packages"))
  (normal-top-level-add-to-load-path '("use-package"
                                       "diminish")))

(eval-when-compile
  (require 'use-package))
(require 'bind-key)
(require 'diminish)

;; Libs
(use-package dash
  :load-path "lib/dash"
  :defer t)

;; Packages
(use-package evil
  :load-path "locked-packages/evil"
  :config
  (evil-mode 1))

(use-package base16-theme
  :load-path "locked-packages/base16-theme"
  :init
  (add-to-list 'custom-theme-load-path "~/.emacs.d/locked-packages/base16-theme/build")
  :config
  (load-theme 'base16-eighties t))

(use-package smartparens
  :load-path "locked-packages/smartparens"
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  :diminish smartparens-mode)

(use-package which-key
  :load-path "locked-packages/which-key"
  :demand t
  :config
  (which-key-mode)
  :commands (which-key-show-top-level)
  :bind ("C-+" . which-key-show-top-level)
  :diminish which-key-mode)

(use-package rainbow-mode
  :load-path "locked-packages/rainbow-mode"
  :defer t
  :commands (rainbow-mode))

(require 'init-telephone-line)
(require 'init-lang)

(provide 'init-packages)
