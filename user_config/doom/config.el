;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; fonts

(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))

;; themes
(setq doom-theme 'doom-one)

;; show line numbers
(setq display-line-numbers-type t)

;; Blinking cursor
(blink-cursor-mode 1)

;; ORG MODEEEEEEE FCK YEAHH
(setq org-directory "~/org/")

(setq org-log-done 'time)
(setq org-log-done 'note)

(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "DONE(d)" "CANCELLED(c)")
        (sequence "TASK(f)" "|" "DONE(d)")
        (sequence "MAYBE(m)" "|" "CANCELLED(c)")))

(setq org-todo-keyword-faces
      '(("TODO" . (:foreground "DarkOrange1" :weight bold))
        ("MAYBE" . (:foreground "sea green"))
        ("DONE" . (:foreground "light sea green"))
        ("CANCELLED" . (:foreground "forest green"))
        ("TASK" . (:foreground "blue"))))


;; show menu bar
;;(menu-bar-mode 1)

;; treemacs
(require 'cfrs)
(require 'treemacs)

(treemacs-git-mode 'deferred)
(global-set-key [(f9)] 'treemacs-select-window)
(global-set-key (kbd "M-0") 'treemacs-select-window)
(setq treemacs-show-hidden-files nil)

(treemacs-fringe-indicator-mode t)
(treemacs-filewatch-mode t)
(setq treemacs-file-event-delay 1000)
;; (treemacs-follow-mode t)
(require 'treemacs-project-follow-mode)
(treemacs-project-follow-mode t)
(treemacs-git-mode 'deferred)
(setq treemacs-is-never-other-window t)
;;(setq treemacs-is-never-other-window nil)
(setq treemacs-silent-refresh    t)

(defun treemacs-ignore-example (filename absolute-path)
  (or (string-suffix-p filename ".elc")
      ;; (string-prefix-p "/x/y/z/" absolute-path)
      ))

(add-to-list 'treemacs-ignored-file-predicates #'treemacs-ignore-example)

(use-package treemacs-icons-dired :after treemacs :config (treemacs-load-theme "icons-dired"))
(doom/set-frame-opacity 85)

;; (use-package treemacs
;;   :ensure t
;;   :after persp-mode
;;   :config
;;   (add-hook 'persp-created-functions
;;             (lambda (_persp)
;;               (treemacs-select-window))))

;; max
(setq max-lisp-eval-depth 10000)
;;(add-hook 'ibuffer-mode-hook #'nerd-icons-ibuffer-mode) ;; this breaks ibuffer-sidebar

;; customization

;; function for duplicate line, doesn't work in org.
(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (forward-line 1)
  (yank)
)
(global-set-key (kbd "C-d") 'duplicate-line)

;;;; Workspace layouts

(defun mio/dev1 ()
  "Layout One"
  (interactive)
  (treemacs)
  (ibuffer-sidebar-show-sidebar)
  (windmove-right)
  (split-window-below (floor (* 0.80 (window-height))))
  (windmove-down)
  (+vterm/here ".")
  (windmove-up)
  (set-window-parameter (split-window-right (floor (* 0.95 (window-width)))) 'window-name 'special)
  (set-window-parameter (selected-window) 'window-name 'normal)
  (dev1/set-display-groups)
  (windmove-left)
  (balance-windows-area))

(defun mio/agenda ()
  "Agenda Layout"
  (interactive)
  (org-mode)
  (setq org-agenda-file '("~/org/"))
  (treemacs)
  ;;(treemacs-add-project-to-workspace "~/org")
  ;;(treemacs-select-directory)
  ;;(treemacs-add-and-display-current-project)
  (ibuffer-sidebar-show-sidebar)
  (windmove-right)
  (split-window-below (floor (* 0.50 (window-height))))
  (windmove-down)
  (org-todo-list)
  (set-window-dedicated-p (selected-window) 1)
  (windmove-up)
  (find-file "~/org/startup.org"))

;; get window by name
(defun dev1/get-window-by-name (name)
  "Get a window by its NAME."
  (catch 'window
    (dolist (window (window-list))
      (when (equal (window-parameter window 'window-name) name)
        (throw 'window window)))))

;; set where to display buffers
(defun dev1/set-display-groups ()
  "Used to display specific buffer to specific window."
  (setq display-buffer-alist
      `((,(regexp-opt '("^\*[a-zA-z0-9\-\ ]*\*$"))
         (dev1/display-buffer-in-named-window)
         (window-name . special))
        (".*"
         (dev1/display-buffer-in-named-window)
         (window-name . normal)))))

(defun dev1/display-buffer-in-named-window (buffer window-name)
  "Display BUFFER in the window named WINDOW-NAME."
  (let ((window (dev1/get-window-by-name window-name)))
    (if window
       (progn
          (set-window-buffer window buffer)
          window)
      (message "No window named %s" window-name)
      (display-buffer buffer))))

(defun dev1/ibuffer-display-buffer ()
  "Display the buffer from ibuffer in the special window."
  (interactive)
  (let ((buffer (ibuffer-current-buffer)))
    (dev1/display-buffer-in-named-window buffer 'special)))

(defun my/treemacs-open-file-in-window (buffer _)
  "Force Treemacs to open files in a specific named window."
  (let ((window (get-buffer-window "normal")))
    (when window
      (select-window window)
      (switch-to-buffer buffer))))

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (define-key ibuffer-mode-map (kbd "RET") 'dev1/ibuffer-display-buffer)))

;; some configs for RUST

;; rustic mode auto-save
(use-package! rustic
  :hook ((rustic-mode . (lambda()
                         (setq-local auto-save-visited-interval 1)
                         (auto-save-mode 1)))))

(after! lsp-ui
  ;;(setq lsp-ui-doc-position 'at-point)
  (setq lsp-ui-doc-position 'top)
  (setq lsp-ui-doc-use-childframe t)
  (setq lsp-ui-doc-max-width 80)
  (setq lsp-ui-doc-max-height 20)
  (setq lsp-ui-doc-enable t))

;; lsp-ui-doc-show
;; lsp-ui-imenu

;; (custom-set-variables
;;  '(lsp-ui-doc-position 'at-point))
(setq lsp-ui-doc-show-with-cursor t)

;; set caro colors for eshell
(setenv "CARGO_TERM_COLOR" "always")
;; set emacsw env for avoid xterm start inside emacs
(setenv "EMACSW" "true")

;; zig zls
;;(setq lsp-zig-zig-exe-path "/home/alejandro/.bin/zls")
