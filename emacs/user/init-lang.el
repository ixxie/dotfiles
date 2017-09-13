;;; -*- lexical-binding: t -*-

;; Rust
(use-package rust-mode
  :ensure t
  :defer t)

(use-package flycheck
  :ensure t
  :defer 5)

(use-package flycheck-rust
  :ensure t
  :defer t
  :after rust-mode
  :config
  (add-hook 'rust-mode-hook #'flycheck-rust-setup)
  (add-hook 'rust-mode-hook #'flycheck-mode))

(use-package cargo
  :ensure t
  :defer t
  :after rust-mode
  :config (add-hook 'rust-mode-hook #'cargo-minor-mode))

;; Clojure
(use-package clojure-mode
  :ensure t
  :defer t)

(use-package rainbow-delimiters
  :ensure t
  :defer t
  :after clojure-mode
  :config (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode))

;; Haskell
(use-package haskell-mode
  :ensure t
  :defer t
  :config (add-hook 'haskell-mode-hook #'interactive-haskell-mode))

(provide 'init-lang)
