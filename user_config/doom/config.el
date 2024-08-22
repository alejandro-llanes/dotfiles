;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;; (after! core-ui (menu-bar-mode 1))
;;(menu-bar-mode 1)

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

;; (setq treemacs-width 30)

;;(require 'treemacs-icons-dired)
;;(treemacs-icons-dired-mode t)
;;(require 'treemacs-all-the-icons)
;;(treemacs-all-the-icons t)
(use-package treemacs-icons-dired :after treemacs :config (treemacs-load-theme "icons-dired"))
(doom/set-frame-opacity 85)

;;(setq display-buffer-base-action
;;     '((display-buffer-reuse-window
;;        display-buffer-use-some-window)))

(defun mio/get-window-by-name (name)
  "Get a window by its NAME."
  (catch 'window
    (dolist (window (window-list))
      (when (equal (window-parameter window 'window-name) name)
        (throw 'window window)))))

(defun mio/set-display-groups ()
  "Used to display specific buffer to specific window."
  (setq display-buffer-alist
      `((,(regexp-opt '("^\*[a-zA-z0-9\-\ ]*\*$"))
         (mio/display-buffer-in-named-window)
         (window-name . special))
        (".*"
         (mio/display-buffer-in-named-window)
         (window-name . normal)))))

(defun mio/layout-1 ()
  "Layout One"
  (interactive)
  (treemacs)
  (ibuffer-sidebar-show-sidebar)
  (windmove-right)
  (split-window-below (floor (* 0.80 (window-height))))
  (windmove-down)
  ;;(eshell)
  ;;(vterm)
  (+vterm/here ".")
  (windmove-up)
  ;;(split-window-right (floor (* 0.95 (window-width))))
  ;;(windmove-right)
  ;;(set-window-parameter (split-window-right) 'window-name 'special)
  (set-window-parameter (split-window-right (floor (* 0.95 (window-width)))) 'window-name 'special)
  ;;(windmove-left)
  (set-window-parameter (selected-window) 'window-name 'normal)
  (mio/set-display-groups)
  (windmove-left)
  (balance-windows-area))

(defun mio/display-buffer-in-named-window (buffer window-name)
  "Display BUFFER in the window named WINDOW-NAME."
  (let ((window (mio/get-window-by-name window-name)))
    (if window
       (progn
          (set-window-buffer window buffer)
          window)
      (message "No window named %s" window-name)
      (display-buffer buffer))))

(defun mio/ibuffer-display-buffer ()
  "Display the buffer from ibuffer in the special window."
  (interactive)
  (let ((buffer (ibuffer-current-buffer)))
    (mio/display-buffer-in-named-window buffer 'special)))

(defun my/treemacs-open-file-in-window (buffer _)
  "Force Treemacs to open files in a specific named window."
  (let ((window (get-buffer-window "normal")))
    (when window
      (select-window window)
      (switch-to-buffer buffer))))

;;(defun mio/treemacs-display-buffer (buffer _alist)
;;  "Display BUFFER in the special window."
;;  (mio/display-buffer-in-named-window buffer 'normal))

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (define-key ibuffer-mode-map (kbd "RET") 'mio/ibuffer-display-buffer)))

;;(add-hook 'treemacs-mode-hook
;;          (lambda ()
;;	    (setq treemacs-display-in-side-window t)
;;	    (setq display-buffer-alist
;;		  `((,(regexp-quote (buffer-name))
;;		      (mio/treemacs-display-buffer))))))

;;(with-eval-after-load 'treemacs
;;		      (add-hook 'treemacs-select-file-hook
;;				(lambda ()
;;				(mio/treemacs-open-file-in-window ))))

(setq max-lisp-eval-depth 10000)
;;(add-hook 'ibuffer-mode-hook #'nerd-icons-ibuffer-mode) ;; this breaks ibuffer-sidebar

(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank)
)
(global-set-key (kbd "C-d") 'duplicate-line)

;; rustic mode auto-save
(use-package! rustic
  :hook ((rustic-mode . (lambda()
                         (setq-local auto-save-visited-interval 1)
                         (auto-save-mode 1)))))

;; documentation location
;; (use-package! lsp-mode
;;   :commands (lsp lsp-deferred)
;;   :hook ((rust-mode . lsp)
;;          (rustic-mode . lsp)))

;; (use-package! lsp-ui
;;   :after lsp-mode
;;   ;;:after lsp-ui
;;   :custom
;;   (lsp-ui-doc-enable t)
;;   ;;(lsp-ui-doc-use-webkit t)
;;   (lsp-ui-doc-position 'at-point)
;;   (lsp-ui-doc-header t)
;;   (lsp-ui-doc-include-signature t)
;;   (lsp-ui-doc-max-width 80)
;;   (lsp-ui-doc-max-height 20)
;;   (lsp-ui-doc-use-childframe t)
;;   ;;(lsp-ui-doc-delay 0.5)
;;   :hook (lsp-mode . lsp-ui-mode))

;; (add-hook 'rust-mode-hook 'lsp-ui-doc-mode )
;; (add-hook 'rustic-mode-hook 'lsp-ui-doc-mode)

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
