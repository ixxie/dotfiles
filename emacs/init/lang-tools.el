;;; -*- lexical-binding: t -*-

;; General
(use-package flycheck
  :defer 5)

;; Haskell
(use-package intero
  :ensure t)
(add-hook 'haskell-mode-hook 'intero-mode)
(require 'haskell-mode)

(provide 'lang-tools)
