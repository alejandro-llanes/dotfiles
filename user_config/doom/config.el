;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-


;; GENERAL

;; environment
;; set cargo colors for eshell
(setenv "CARGO_TERM_COLOR" "always")
;; set emacsw env for avoid tmux start inside emacs
(setenv "EMACSW" "true")

;; opacity
(doom/set-frame-opacity 85)

;; show line numbers
(setq display-line-numbers-type t)

;; avoid ESC close buffers
(remove-hook 'doom-escape-hook '+popup-close-on-escape-h)

;; stop creating a new workspace at connect to server
;(after! persp-mode
;  (setq persp-emacsclient-init-frame-behaviour-override "main"))

;; max recursion
(setq max-lisp-eval-depth 10000)

;; cycling windows
(global-set-key (kbd "C-<down>") 'enlarge-window)
(global-set-key (kbd "C-<up>") 'shrink-window)
(global-set-key (kbd "C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "C-<right>") 'enlarge-window-horizontally)

;; VTERM
;;(define-key vterm-mode-map (kbd "C-c C-c") 'vterm--self-ctrl-c)

;; FONTS

(setq doom-font (font-spec :family "Fira Code" :size 16 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 18))


;; THEMES
;; [[https://github.com/doomemacs/themes/tree/screenshots][themes]]
;;(setq doom-theme 'doom-one)
;;(setq doom-theme 'doom-vibrant)
;;(setq doom-theme 'doom-acario-dark)
;;;(setq doom-theme 'doom-dracula)
;;(setq doom-theme 'doom-gruvbox)
(setq doom-theme 'doom-laserwave)
;;(setq doom-theme 'doom-gruvbox)
;;(setq doom-theme 'doom-outrun-electric)
;;(setq doom-theme 'doom-solarized-dark)
;;;(setq doom-theme 'doom-nord-light)

;; SCROLLING

(pixel-scroll-precision-mode)
(setq pixel-scroll-mode 1)
(setq mouse-wheel-tilt-scroll t)
(setq pixel-scroll-precision-use-momentum 1)

;;(good-scroll-mode 1)
;;(global-set-key (kbd "<prior>") 'good-scroll-down)  ;; Bind PgUp to inertia scroll down
;;(global-set-key (kbd "<next>") 'good-scroll-up)     ;; Bind PgDn to inertia scroll up

;; SWITCHING
(windmove-default-keybindings 'super)

;; CURSOR

(blink-cursor-mode 1)
(beacon-mode 1)
(after! beacon-mode
  (setq beacon-blink-duration 0.5)
  (setq beacon-blink-delay 0.5))


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


;; POPUP ORG-CAPTURE


(defvar mio-capture-frame "Mio Capture" "The name of the workspace for org capture.")

(defun mio/org-capture ()
  "Custom org capture popup."
  (interactive)
  (+workspace/new-named mio-capture-frame)
  (org-capture)
  (delete-other-windows))

(defun mio/post-capture-action ()
  "To run after finalize org capture."
  (interactive)
  (when (persp-with-name-exists-p mio-capture-frame)
    (persp-kill mio-capture-frame)
    (delete-frame)))

(advice-add 'org-capture-finalize :after #'mio/post-capture-action)


;; TREEMACS

(require 'cfrs)
(require 'treemacs)
(setq treemacs-show-hidden-files nil)
(treemacs-fringe-indicator-mode t)
(treemacs-filewatch-mode t)
(setq treemacs-file-event-delay 1000)

(require 'treemacs-project-follow-mode)
(setq treemacs-project-follow-mode nil)
(setf treemacs-follow-mode nil)
(treemacs-git-mode 'deferred)
(setq treemacs-is-never-other-window t)
(setq treemacs-silent-refresh    t)

(defun treemacs-ignore-example (filename absolute-path)
  (or (string-suffix-p filename ".elc")
      ;; (string-prefix-p "/x/y/z/" absolute-path)
      ))

(add-to-list 'treemacs-ignored-file-predicates #'treemacs-ignore-example)

(use-package treemacs-icons-dired
  :after treemacs
  ;;:config (treemacs-load-theme "icons-dired"))
  :config (treemacs-icons-dired-mode))


(use-package treemacs-persp
  :after (treemacs persp-mode)
  ;;:ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(add-hook 'projectile-after-switch-project-hook 'treemacs-display-current-project-exclusively)

(require 'lsp-treemacs)
(lsp-treemacs-sync-mode 1)

;; MINIBUFFER


(require 'vertico)
(require 'vertico-posframe)
(require 'marginalia)
(vertico-mode)
(vertico-posframe-mode 1)
(marginalia-mode)
(setq vertico-posframe-poshandler #'posframe-poshandler-frame-top-center)


;; IBUFFER

;; https://emacs.stackexchange.com/questions/27749/how-can-i-hide-unwanted-buffers-when-cycling-with-c-x-left-right 

(defun mio/ibuffer-ace-window-display ()
  "Use ace-window to select a window to display the buffer from ibuffer."
  (interactive)
  (let ((buf (ibuffer-current-buffer)))
    (if buf
        (let ((aw-flip-keys nil)) ; Disable flipping of keys in ace-window
          (ace-select-window)     ; Use ace-window to select a window
          (switch-to-buffer buf)) ; Display the selected buffer
      (message "No buffer selected!"))))

(with-eval-after-load 'ibuffer
  ;; Bind the function to a key in `ibuffer` mode, for example, "a"
  (define-key ibuffer-mode-map (kbd "o") 'mio/ibuffer-ace-window-display))


;; '(("Group Title"
;;   ("Label"   (type  . value))))

(setq ibuffer-saved-filter-groups
      '(("MyList"
         ("Unsaved" (modified))                      ; All unsaved buffers
         ("Stars"   (starred-name))                  ; Group *starred*
         ("Start"   (name          . "*scratch\\*")) ; By regexp
         ("Dired"   (mode          . dired-mode))    ; Filter by mode
         ("Org"     (filename      . ".org"))        ; By filename
         ;;("Scheme"  (directory     . "~/scheme*"))   ; By directory
         ("Gnus" (or                                 ; Or multiple!
	          (saved        . "gnus")
	          (derived-mode . bbdb-mode))))))

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-switch-to-saved-filter-groups "MyList")
            (setq-local display-buffer-base-action '(display-buffer-use-some-window))
            ))


;; CUSTOM FUNCTIONS


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

;; Workspace layouts

(defun mio/dev1 ()
  "Layout One"
  (interactive)
  (treemacs-set-scope-type 'Perspectives)
  (treemacs)
  (ibuffer-sidebar-show-sidebar)
  (windmove-right)
  (split-window-below (floor (* 0.80 (window-height))))
  (windmove-down)
  (+vterm/here ".")
  (set-window-dedicated-p (selected-window) 1)
  (windmove-up)
  (set-window-parameter (split-window-right (floor (* 0.95 (window-width)))) 'window-name 'special)
  (set-window-parameter (selected-window) 'window-name 'normal)
  (windmove-left)
  ;;(lsp-ui-menu)
  (balance-windows-area)
  ;;  (minimap-mode 1)
  (setq treemacs-follow-after-init nil)
  (setq pop-up-windows nil))

(defun mio/agenda ()
  "Agenda Layout"
  (interactive)
  (org-mode)
  (setq org-agenda-file '("~/org/"))
  (require 'treemacs)
  ;;(treemacs-add-project-to-workspace "~/org/" "Org Files" )
  ;;(treemacs-switch-workspace "~/org/" )
  (treemacs--find-workspace-by-name "org")
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
  (find-file "~/org/startup.org")
  (setq treemacs-follow-after-init nil)
  (setq pop-up-windows nil))


(defun mio/terra ()
  "Terraform Layout"
  (interactive)
  (treemacs-set-scope-type 'Perspectives)
  (treemacs)
  (lsp-treemacs-symbols)
  (ibuffer-sidebar-show-sidebar)
  (windmove-right)
  (split-window-below (floor (* 0.80 (window-height))))
  (windmove-down)
  (+vterm/here ".")
  (set-window-dedicated-p (selected-window) 1)
  (windmove-up)
  ;;(set-window-parameter (split-window-right (floor (* 0.95 (window-width)))) 'window-name 'special)
  (set-window-parameter (selected-window) 'window-name 'normal)
  (windmove-left)
  ;;(lsp-ui-menu)
  ;;(balance-windows-area)
  (minimap-mode 1)
  (setq treemacs-follow-after-init nil)
  (setq pop-up-windows nil))

;; LANGUAGES SPECIFIC

;; MAGIT FANCY
(use-package! magit-file-icons
  :ensure t
  :after magit
  :init
  (magit-file-icons-mode 1)
  :custom
  ;; These are the default values:
  (magit-file-icons-enable-diff-file-section-icons t)
  (magit-file-icons-enable-untracked-icons t)
  (magit-file-icons-enable-diffstat-icons t))

;; LSP
(after! lsp-ui
  ;;(setq lsp-ui-doc-position 'at-point)
  (setq lsp-ui-doc-position 'top)
  (setq lsp-ui-doc-use-childframe t)
  (setq lsp-ui-doc-max-width 80)
  (setq lsp-ui-doc-max-height 20)
  ;;(setq lsp-ui-doc-enable t)
  (setq lsp-ui-doc-show nil)
  )

(setq lsp-ui-doc-show-with-cursor 1)
;;(setq lsp-ui-doc-show-with-cursor nil)
(global-set-key (kbd "<C-tab>") 'lsp-ui-doc-focus-frame)
;;(global-set-key (kbd "s-k") 'lsp-ui-doc-show)
;;(map! :n "s-k" #'lsp-ui-doc-show)


;; RUST
;; rustic mode auto-save
(use-package! rustic
  :hook ((rustic-mode . (lambda()
                          (setq-local auto-save-visited-interval 1)
                          (auto-save-mode 1)))))

(if buffer-file-name
        (setq-local buffer-save-without-query t))

;; PYTHON
;;(add-hook 'python-mode-hook 'py-autopep8-mode)
;;;(use-package! lsp-pyright
;;;              :ensure t
;;;              :custom (lsp-pyright-langserver-command "pyright")
;;;              :hook (python-mode . (lambda () 
;;;                                     (require 'lsp-pyright')
;;;                                     (lsp))))

;;(add-hook 'python-mode-hook 'ruff-format-on-save-mode)
(setq ruff-format-on-save-mode 1)

;; LUA
;; Associate .vim files with lua-mode
(setq auto-mode-alist
      (append '((".*\\.vim\\'" . lua-mode))
              auto-mode-alist))

;; TERRAFORM

(setq lsp-auto-guess-root nil)
;;(add-to-list 'lsp-directory-blacklist "~")
(setq lsp-disabled-clients '(tfm-ls tfls semgrep-ls))
;;(setq lsp-enabled-clients '(terraform-ls))
(setq ls-terraform-ls-server "/usr/local/bin/terraform-ls")
