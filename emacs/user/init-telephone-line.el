;;; -*- lexical-binding: t -*-

(use-package telephone-line
  :ensure t
  :init
  ;; Config modeline
  (setq telephone-line-lhs
        '((evil . (telephone-line-evil-tag-segment))
          (accent . (telephone-line-vc-segment
                     telephone-line-erc-modified-channels-segment
                     telephone-line-process-segment))
          (nil . (telephone-line-minor-mode-segment
                  telephone-line-buffer-segment))))
  (setq telephone-line-rhs
        '((nil . (telephone-line-misc-info-segment))
          (accent . (telephone-line-major-mode-segment))
          (evil . (telephone-line-airline-position-segment))))

  ;; Set the faces to better match base16-eighties
  (custom-theme-set-faces 'base16-eighties '(mode-line
                                             ((t (:foreground "#f99157" :background "#515151")))))
  (custom-theme-set-faces 'base16-eighties '(telephone-line-accent-active
                                             ((t (:foreground "#f99157" :background "#393939" :inherit mode-line)))))
  (custom-theme-set-faces 'base16-eighties '(telephone-line-accent-inactive
                                             ((t (:foreground "#000000" :background "#747369" :inherit mode-line-inactive)))))
  (custom-theme-set-faces 'base16-eighties '(telephone-line-evil
                                             ((t (:foreground "#2d2d2d" :weight bold :inherit mode-line)))))
  (custom-theme-set-faces 'base16-eighties '(telephone-line-evil-insert
                                             ((t (:background "#6699cc" :inherit telephone-line-evil)))))
  (custom-theme-set-faces 'base16-eighties '(telephone-line-evil-normal
                                             ((t (:background "#99cc99" :inherit telephone-line-evil)))))
  (custom-theme-set-faces 'base16-eighties '(telephone-line-evil-visual
                                             ((t (:background "#cc99cc" :inherit telephone-line-evil)))))
  (custom-theme-set-faces 'base16-eighties '(telephone-line-evil-replace
                                             ((t (:background "#e8e6df" :inherit telephone-line-evil)))))
  (custom-theme-set-faces 'base16-eighties '(telephone-line-evil-motion
                                             ((t (:background "#f2777a" :inherit telephone-line-evil)))))
  (custom-theme-set-faces 'base16-eighties '(telephone-line-evil-operator
                                             ((t (:background "#ffcc66" :inherit telephone-line-evil)))))
  (custom-theme-set-faces 'base16-eighties '(telephone-line-evil-emacs
                                             ((t (:background "#66cccc" :inherit telephone-line-evil)))))
  :config
  (telephone-line-mode t))

(provide 'init-telephone-line)
