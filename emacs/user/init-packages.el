;;; -*- lexical-binding: t -*-

;; Path for `use-package` and its dependency
(let ((default-directory (expand-file-name "lock" user-emacs-directory)))
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
  :load-path "lock/evil"
  :config
  (evil-mode 1))

(use-package base16-theme
  :load-path "lock/base16-theme"
  :init
  (add-to-list 'custom-theme-load-path (expand-file-name "lock/base16-theme/build" user-emacs-directory))
  :config
  (load-theme 'base16-eighties t))

(use-package smartparens
  :load-path "lock/smartparens"
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  :diminish smartparens-mode)

(use-package which-key
  :load-path "lock/which-key"
  :demand t
  :config
  (which-key-mode)
  :commands (which-key-show-top-level)
  :bind ("C-+" . which-key-show-top-level)
  :diminish which-key-mode)

(use-package rainbow-mode
  :load-path "lock/rainbow-mode"
  :defer t
  :commands (rainbow-mode))

(require 'init-telephone-line)
(require 'init-lang)

(provide 'init-packages)
