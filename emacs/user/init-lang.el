;;; -*- lexical-binding: t -*-

;; General
(use-package flycheck
  :load-path "locked-packages/flycheck"
  :defer 5)

;; Rust
(use-package rust-mode
  :load-path "locked-packages/rust-mode"
  :defer t)

(use-package flycheck-rust
  :load-path "locked-packages/flycheck-rust"
  :defer t
  :after rust-mode
  :config
  (add-hook 'rust-mode-hook #'flycheck-mode)
  (add-hook 'rust-mode-hook #'flycheck-rust-setup))

;; Clojure
(use-package clojure-mode
  :load-path "locked-packages/clojure-mode"
  :defer t)

(use-package rainbow-delimiters
  :load-path "locked-packages/rainbow-delimiters"
  :defer t
  :after clojure-mode
  :config (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode))

;; Haskell
(use-package haskell-mode
  :load-path "locked-packages/haskell-mode"
  :defer t
  :config (add-hook 'haskell-mode-hook #'interactive-haskell-mode))

(use-package flycheck-haskell
  :load-path "locked-packages/flycheck-haskell"
  :defer t
  :after haskell-mode
  :config
  (add-hook 'haskell-mode-hook #'flycheck-mode)
  (add-hook 'haskell-mode-hook #'flycheck-haskell-setup))

(provide 'init-lang)
