;;; -*- lexical-binding: t -*-

;; Define packages to download in a list
(defvar my-packages '(clojure-mode
                      haskell-mode
                      rust-mode
                      base16-theme
                      telephone-line
                      rainbow-mode
                      rainbow-delimiters
                      smartparens
                      cider
                      cargo
                      which-key))

;; Install if missing
(dolist (p my-packages)
  (unless (package-installed-p p)
    (package-install p)))

(load-theme 'base16-eighties t)

(require 'smartparens-config)
(smartparens-global-mode t)

(require 'init-telephone-line)
(require 'init-lang)

(require 'which-key)
(which-key-mode)

(require 'evil)
(evil-mode 1)

(provide 'init-packages)
