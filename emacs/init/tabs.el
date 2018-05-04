;; Tabbar
(require 'tabbar)

;; Group tabs by frame
;; by lawlist on stackoverflow
;; https://emacs.stackexchange.com/questions/10081/browser-style-tabs-for-emacs

;; Tab cycle scope
(setq tabbar-cycle-scope 'tabs)

(remove-hook 'kill-buffer-hook 'tabbar-buffer-track-killed)

;; customize to show all normal files in one group
 (defun my-buffer-groups () 
   "Returns the name of the tab group names the current buffer belongs to.
 There are two groups: Emacs buffers (those whose name starts with '*', plus
 dired buffers), and the rest.  This works at least with Emacs v24.2 using
 tabbar.el v1.7."
   (list (cond ((string-equal "*" (substring (buffer-name) 0 1)) "emacs")
               ((eq major-mode 'dired-mode) "emacs")
               (t "user"))))

(setq tabbar-buffer-groups-function 'my-buffer-groups) ;; 'tabbar-buffer-groups

;; AUTHOR:  Alp Aker -- https://github.com/alpaker/Frame-Bufs
;; @lawlist extracted/revised the function(ality) from said library.
(defun my-buffer-list (frame)
  ;; Remove dead buffers.
  (set-frame-parameter frame 'frame-bufs-buffer-list
    (delq nil (mapcar #'(lambda (x) (if (buffer-live-p x) x))
      (frame-parameter frame 'frame-bufs-buffer-list))))
  ;; Return the associated-buffer list.
  (frame-parameter frame 'frame-bufs-buffer-list) )

;; AUTHOR:  Alp Aker -- https://github.com/alpaker/Frame-Bufs
;; @lawlist extracted/revised the function(ality) from said library.
(defun my-add-buffer (&optional buf frame)
"Add BUF to FRAME's associated-buffer list if not already present."
(interactive)
  (let* (
      (buf (if buf buf (current-buffer)))
      (frame (if frame frame (selected-frame)))
      (associated-bufs (frame-parameter frame 'frame-bufs-buffer-list)))
    (unless (bufferp buf)
      (signal 'wrong-type-argument (list 'bufferp buf)))
    (unless (memq buf associated-bufs)
      (set-frame-parameter frame 'frame-bufs-buffer-list (cons buf associated-bufs)))
    (when tabbar-mode (tabbar-display-update)) ))


;; AUTHOR:  Alp Aker -- https://github.com/alpaker/Frame-Bufs
;; @lawlist extracted/revised the function(ality) from said library.
(defun my-remove-buffer (&optional buf frame)
"Remove BUF from FRAME's associated-buffer list."
(interactive)
  (let* (
      (buf (if buf buf (current-buffer)))
      (frame (if frame frame (selected-frame))))
    (set-frame-parameter frame 'frame-bufs-buffer-list
      (delq buf (frame-parameter frame 'frame-bufs-buffer-list)))
   (when tabbar-mode (tabbar-display-update))))

;; AUTHOR:  Alp Aker -- https://github.com/alpaker/Frame-Bufs
;; @lawlist extracted/revised the function(ality) from said library.
(defun my-buffer-list-reset ()
    "Wipe the entire slate clean for the selected frame."
  (interactive)
  (modify-frame-parameters
    (selected-frame)
    (list (cons 'frame-bufs-buffer-list nil)))
  (when tabbar-mode (tabbar-display-update)))

(defun my-switch-tab-group ()
"Switch between tab group `A` and `N`."
(interactive)
  (let* (
      (current-group (format "%s" (tabbar-current-tabset t)))
      (tab-buffer-list (mapcar
          #'(lambda (b)
              (with-current-buffer b
                (list (current-buffer)
                      (buffer-name)
                      (funcall tabbar-buffer-groups-function) )))
               (funcall tabbar-buffer-list-function))) )
    (catch 'done
      (mapc
        #'(lambda (group)
            (when (not (equal current-group
                          (format "%s" (car (car (cdr (cdr group)))))))
              (throw 'done (switch-to-buffer (car (cdr group))))))
        tab-buffer-list) )))

(defsubst tabbar-line-tab (tab)
  "Return the display representation of tab TAB.
That is, a propertized string used as an `header-line-format' template
element.
Call `tabbar-tab-label-function' to obtain a label for TAB."
  (concat
    (propertize
      (if tabbar-tab-label-function
          (funcall tabbar-tab-label-function tab)
        tab)
      'tabbar-tab tab
      'local-map (tabbar-make-tab-keymap tab)
      'help-echo 'tabbar-help-on-tab
      'mouse-face 'tabbar-highlight
      'face
        (cond
          ((and
              (tabbar-selected-p tab (tabbar-current-tabset))
              (memq (current-buffer) (my-buffer-list (selected-frame))))
            'tabbar-selected-associated)
          ((and
              (not (tabbar-selected-p tab (tabbar-current-tabset)))
              (memq (current-buffer) (my-buffer-list (selected-frame))))
            'tabbar-unselected-associated)
          ((and
              (tabbar-selected-p tab (tabbar-current-tabset))
              (not (memq (current-buffer) (my-buffer-list (selected-frame)))))
            'tabbar-selected-unassociated)
          ((and
              (not (tabbar-selected-p tab (tabbar-current-tabset)))
              (not (memq (current-buffer) (my-buffer-list (selected-frame)))))
            'tabbar-unselected-unassociated))
      'pointer 'hand)
    tabbar-separator-value))

(define-key global-map "\C-c\C-r" 'my-buffer-list-reset)

(define-key global-map "\C-c\C-a" 'my-add-buffer)

(define-key global-map "\C-c\C-n" 'my-remove-buffer)

(define-key global-map (kbd "<M-s-right>") 'tabbar-forward)

(define-key global-map (kbd "<M-s-left>") 'tabbar-backward)

(define-key global-map [C-tab] 'my-switch-tab-group)



;; Tabbar style

;; Colors
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
                    (format " [%s] " (tabbar-tab-tabset tab))
                  (format " %s " (tabbar-tab-value tab)))))
    ;; Unless the tab bar auto scrolls to keep the selected tab
    ;; visible, shorten the tab label to keep as many tabs as possible
    ;; in the visible area of the tab bar.
    (if tabbar-auto-scroll-flag
        label
      (tabbar-shorten
       label (max 1 (/ (window-width)
                       (length (tabbar-view
                                (tabbar-current-tabset)))))))))
;; Activate tabbar
(tabbar-mode 1)

(provide 'tabs)

