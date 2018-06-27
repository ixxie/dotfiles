;;; -*- lexical-binding: t -*-

;; General
(use-package flycheck
  :config
  :defer 5)

(add-hook 'after-init-hook #'global-flycheck-mode)
;; Haskell
;;(use-package intero
;;  :ensure t)
;;(add-hook 'haskell-mode-hook 'intero-mode)
(require 'haskell-mode)

(provide 'lang-tools)
