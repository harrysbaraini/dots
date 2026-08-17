;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(server-start)

;; Hide frame
(add-to-list 'default-frame-alist '(undecorated . t))

;; Some functionality uses this to identify you, e.g. GPG configuration, email clients, file templates and snippets.
(setq user-full-name "Vanderlei Sbaraini"
      user-mail-address "hey@vans.dev")

;; Font settings. See 'C-h v doom-font' for documentation and more examples of what they accept.
(setq doom-font (font-spec :family "GeistMono Nerd Font" :size 14)
      doom-variable-pitch-font (font-spec :family "GeistMono Nerd Font" :size 14))

;; Line spacing.
(setq-default line-spacing .15)

;; Relative line numbers.
(setq display-line-numbers-type 'relative)

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

;; Theming
;; (setq doom-theme 'doom-dark+)

(defun my-apply-theme (appearance)
  "Load theme based on MACOS APPEARANCE (light or dark)."
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (load-theme 'doom-earl-grey t))
    ('dark (load-theme 'doom-dark+ t))))

(add-hook 'ns-system-appearance-change-functions #'my-apply-theme)

;; Turn off highlighting current line
(add-hook 'text-mode-hook (lambda () (hl-line-mode -1)))

;; org-mode settings
(defun my/format-org-prop (name value)
  "Return a property line ':NAME: VALUE', or empty string if VALUE is blank."
  (if (or (null value) (string-blank-p value))
      ""
    (format ":%s: %s\n" name value)))

(after! org
  (setq org-directory "~/org/")

  (setq org-capture-templates
    '(
      ("t" "Tasks")
      ("ti" "Inbox Todo" entry (file+headline +org-capture-todo-file "Inbox")
       "* TODO %? %^G \nDEADLINE: %^{Deadline}t \n:PROPERTIES: \n:Created: %U \n%(my/format-org-prop  \n%(my/format-org-prop \"Link\" \"%^{Link}\") \n:END: \n%i\n%a"
       :prepend t)
      ("tw" "Work Tasks" entry (file+headline +org-capture-todo-file "Work Tasks")
       "* TODO %? %^G \nDEADLINE: %^{Deadline}t \n:PROPERTIES: \n:Created: %U \n%(my/format-org-prop  \n%(my/format-org-prop \"Link\" \"%^{Link}\") \n:END: \n%i\n%a"
       :prepend t)

      ("tp" "Personal Tasks" entry (file+headline +org-capture-todo-file "Personal Tasks")
       "* TODO %? %^G \nDEADLINE: %^{Deadline}t \n:PROPERTIES: \n:Created: %U \n%(my/format-org-prop  \n%(my/format-org-prop \"Link\" \"%^{Link}\") \n:END: \n%i\n%a"
       :prepend t)

      ("j" "Journal" entry (file+datetree "journal.org")
       "* Journal :org: \n:PROPERTIES: \n:Via: \n:Note: \n:END: \n:LOGBOOK: \n- State \"\"           from \"\"           %U \n:END: \n%t \n\n  %?"
       :clock-in t
       :clock-resume t
       :empty-lines 1)

      ("n" "Note" entry (file "notes.org")
       "* %? :NOTE:\n%U\n%a\n"
       :clock-in t
       :clock-resume t
       :empty-lines 1)
    ))

  ;; 2. Custom Workflow States (The Smart Keywords)
  (setq org-todo-keywords
        '((sequence
           "TODO(t!)"                    ; Actionable item
           "NEXT(n)"                    ; Immediate next action
           "|"
           "DONE(d!)")
          (sequence
           "REPEAT(e)"                  ; Recurring tasks/habits
           "|"
           "DONE")
          (sequence
           "HOLD(h@)"                    ; Paused task
           "PROJ(p)"                    ; Project with sub-tasks (supports cookies)
           "WAIT(w@)"                    ; Delegated task
           "|"
           "STOP(c!)")))                 ; Cancelled task

  ;; Keyword Colors
  (setq org-todo-keyword-faces
        '(("NEXT" . +org-todo-active)
          ("HOLD" . +org-todo-onhold)
          ("PROJ" . +org-todo-project)
          ("WAIT" . +org-todo-onhold)
          ("STOP" . +org-todo-cancel)))

  (load! "lisp/agenda")

  ;; 4. Clocking & History Setup
  (setq org-clock-persist 'history
        org-agenda-start-with-log-mode t)

  (org-clock-persistence-insinuate))

;; 5. Habit Tracking Module
(use-package! org-habit
  :after org
  :config
  (setq org-habit-show-all-today t))

;; PHP lsp server
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(php-mode . ("phpantom_lsp"))))

;; (after! lsp-mode
;;   (lsp-register-client
;;    (make-lsp-client
;;     :new-connection (lsp-stdio-connection '("phpantom_lsp"))
;;     :activation-fn (lsp-activate-on "php")
;;     :server-id 'phpantom)))

;; Import configs
(load! "lisp/dashboard")
(load! "lisp/clipboard")
(load! "lisp/projects")
