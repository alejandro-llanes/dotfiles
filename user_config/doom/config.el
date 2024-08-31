;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-


;; GENERAL

;; environment
;; set cargo colors for eshell
(setenv "CARGO_TERM_COLOR" "always")
;; set emacsw env for avoid xterm start inside emacs
(setenv "EMACSW" "true")

;; show line numbers
(setq display-line-numbers-type t)

;; avoid ESC close buffers
(remove-hook 'doom-escape-hook '+popup-close-on-escape-h)

;; stop creating a new workspace at connect to server
(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override "main"))

;; max
(setq max-lisp-eval-depth 10000)


;; FONTS

(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))


;; THEMES

(setq doom-theme 'doom-one)


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

(use-package treemacs-icons-dired :after treemacs :config (treemacs-load-theme "icons-dired"))
(doom/set-frame-opacity 85)

(use-package treemacs-persp
  :after (treemacs persp-mode)
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))


;; MINIBUFFER


(require 'vertico)
(require 'vertico-posframe)
(require 'marginalia)
(vertico-mode)
(vertico-posframe-mode 1)
(marginalia-mode)
(setq vertico-posframe-poshandler #'posframe-poshandler-frame-top-center)


;; IBUFFER


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
  (balance-windows-area)
  (setq treemacs-follow-after-init nil)
  (setq pop-up-windows nil))

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
  (find-file "~/org/startup.org")
  (setq treemacs-follow-after-init nil)
  (setq pop-up-windows nil))


;; LANGUAGES SPECIFIC

;; LSP
(after! lsp-ui
  ;;(setq lsp-ui-doc-position 'at-point)
  (setq lsp-ui-doc-position 'top)
  (setq lsp-ui-doc-use-childframe t)
  (setq lsp-ui-doc-max-width 80)
  (setq lsp-ui-doc-max-height 20)
  (setq lsp-ui-doc-enable t))

(setq lsp-ui-doc-show-with-cursor t)

;; RUST
;; rustic mode auto-save
(use-package! rustic
  :hook ((rustic-mode . (lambda()
                          (setq-local auto-save-visited-interval 1)
                          (auto-save-mode 1)))))
