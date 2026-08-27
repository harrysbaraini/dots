;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Some functionality uses this to identify you, e.g. GPG configuration, email clients, file templates and snippets.
(setq user-full-name "Vanderlei Sbaraini"
      user-mail-address "hey@vans.dev")

(defun my/custom-doom-ascii-banner ()
  (propertize
   (string-join
    '("█   █  ███  █   █  ████     ████  █████ █   █   "
      "█░  █░█ ░░█ ██  █░█ ░░░░    █░░░█ █░░░░░█░  █░  "
      "█░░ █░█████░█░█ █░░███░░░   █░░░█░████░░█░░ █░░ "
      " █░█ ░█░░░█░█░░██░░ ░░█  █  █░░ █░█░░░░  █░█ ░░ "
      "  █ ░ █░░░█░█░░ █░████░░ █░ ████ ░█████░  █ ░ ░ "
      "   ░ ░ ░░  ░░░░  ░░░░░░ ░ ░░ ░░░░ ░░░░░░   ░ ░  "
      "    ░   ░   ░ ░   ░ ░░░░   ░  ░░░░  ░░░░░   ░   ")
    "\n")
   'face '+dashboard-banner))

(setq +dashboard-ascii-banner-fn #'my/custom-doom-ascii-banner)

;; Hide frame
(add-to-list 'default-frame-alist '(undecorated . t))

;; Disable top bar
(tab-bar-mode -1)

;; Font settings. See 'C-h v doom-font' for documentation and more examples of what they accept.
(add-hook 'org-mode-hook 'mixed-pitch-mode)

(setq doom-font (font-spec :family "0xProto Nerd Font" :size 16 :slant 'normal :height 1.5)
      doom-variable-pitch-font (font-spec :family "Alegreya" :size 16 :slant 'normal :height 1.5))

;; Line spacing.
(setq-default line-spacing .15)

;; Relative line numbers.
(setq display-line-numbers-type 'relative)

;; Turn off highlighting current line
(add-hook 'text-mode-hook (lambda () (hl-line-mode -1)))

;; Blink cursor for about ten seconds with a calm 3/4 second interval.
(blink-cursor-mode 1)
(setq blink-cursor-interval 0.75
      blink-cursor-blinks (ceiling (/ 10.0 blink-cursor-interval)))

;; protesilaos's spacious padding configuration
(use-package spacious-padding
  :ensure t
  :config
  (setq spacious-padding-widths
        '( :internal-border-width 12
           :header-line-width 4
           :mode-line-width 4
           :custom-button-width 3
           :tab-width 4
           :right-divider-width 30
           :scroll-bar-width 6
           :fringe-width 6))

    (spacious-padding-mode 1))

;; auto theming based on system color mode
(defun my-apply-theme (appearance)
  "Load theme based on SYSTEM APPEARANCE (light or dark)."
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (load-theme 'modus-operandi t))
    ('dark (load-theme 'modus-vivendi t))))

(add-hook 'ns-system-appearance-change-functions #'my-apply-theme)

;; Show workspace tabs in status bar
(setq doom-modeline-persp-name t)
(setq doom-modeline-display-default-persp-name t)

;; Enable auto-save and backup
(setq auto-save-default t
      make-backup-files t)

;; agent-shell
(use-package agent-shell
    :ensure t
    :ensure-system-package
    ((codex-acp . "npm install -g @agentclientprotocol/codex-acp")))

;; PHP lsp server
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(php-mode . ("phpantom_lsp"))))

;; nix
 ;; (after! nix-mode
 ;;  (setq-default nix-indent-function 'nix-indent-line)
 ;;  (setq-default smie-indent-basic 2)
 ;;  (setq-default tab-width 2))

;; Import configs
(load! "+org")
(load! "+clipboard")
(load! "+dashboard")
(load! "+projects")
