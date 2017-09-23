;;; -*- lexical-binding: t -*-

(use-package telephone-line
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


;; tabbar-tweak.el by github user 3demax

;; Tabbar
(require 'tabbar)
;; Tabbar settings
(set-face-attribute
 'tabbar-default nil
 :background "gray20"
 :foreground "gray20"
 :box '(:line-width 1 :color "gray20" :style nil))
(set-face-attribute
 'tabbar-unselected nil
 :background "gray30"
 :foreground "white"
 :box '(:line-width 5 :color "gray30" :style nil))
(set-face-attribute
 'tabbar-selected nil
 :background "gray75"
 :foreground "black"
 :box '(:line-width 5 :color "gray75" :style nil))
(set-face-attribute
 'tabbar-highlight nil
 :background "white"
 :foreground "black"
 :underline nil
 :box '(:line-width 5 :color "white" :style nil))
(set-face-attribute
 'tabbar-button nil
 :box '(:line-width 1 :color "gray20" :style nil))
(set-face-attribute
 'tabbar-separator nil
 :background "gray20"
 :height 0.6)

;; Change padding of the tabs
;; we also need to set separator to avoid overlapping tabs by highlighted tabs
(custom-set-variables
 '(tabbar-separator (quote (0.5))))
;; adding spaces
(defun tabbar-buffer-tab-label (tab)
  "Return a label for TAB.
That is, a string used to represent it on the tab bar."
  (let ((label  (if tabbar--buffer-show-groups
                    (format "[%s]  " (tabbar-tab-tabset tab))
                  (format "%s  " (tabbar-tab-value tab)))))
    ;; Unless the tab bar auto scrolls to keep the selected tab
    ;; visible, shorten the tab label to keep as many tabs as possible
    ;; in the visible area of the tab bar.
    (if tabbar-auto-scroll-flag
        label
      (tabbar-shorten
       label (max 1 (/ (window-width)
                       (length (tabbar-view
                                (tabbar-current-tabset)))))))))

(tabbar-mode 1)


(provide 'style)
