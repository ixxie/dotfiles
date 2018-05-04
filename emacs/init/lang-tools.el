;;; -*- lexical-binding: t -*-

;; General
(use-package flycheck)

(use-package flycheck-pycheckers
  :init
  (global-flycheck-mode 1)
  (with-eval-after-load 'flycheck
  (add-hook 'flycheck-mode-hook #'flycheck-pycheckers-setup))
  :config
  (setq flycheck-pycheckers-checkers "flake8")
  )

;; Haskell
;;(use-package intero
;;  :ensure t)
;;(add-hook 'haskell-mode-hook 'intero-mode)
(require 'haskell-mode)

(provide 'lang-tools)
