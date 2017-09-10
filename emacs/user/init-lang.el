;;; -*- lexical-binding: t -*-

;; Clojure
(add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)

;; Rust
(add-hook 'rust-mode-hook #'cargo-minor-mode)
(add-hook 'rust-mode-hook #'flycheck-mode)
(add-hook 'rust-mode-hook #'flycheck-rust-setup)

;; Haskell
(add-hook 'haskell-mode-hook #'interactive-haskell-mode)

(provide 'init-lang)
