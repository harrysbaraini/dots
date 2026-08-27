;;; agenda.el -*- lexical-binding: t; -*-

;; ui
(setq org-hide-emphasis-markers t      ; hide *bold*, /italic/ markers
      org-ellipsis " …"                ; nicer folded-content indicator
      org-hide-leading-stars t         ; hide leading stars on headlines
      org-startup-indented t)

(custom-theme-set-faces!
  'user
  '(org-level-1 :inherit variable-pitch :weight bold :height 1.25 :foreground "#51afef")
  '(org-level-2 :inherit variable-pitch :weight bold :height 1.18 :foreground "#c678dd")
  '(org-level-3 :inherit variable-pitch :weight semi-bold :height 1.12 :foreground "#98be65")
  '(org-level-4 :inherit variable-pitch :weight semi-bold :height 1.07 :foreground "#da8548")
  '(org-level-5 :inherit variable-pitch :weight normal :height 1.04 :foreground "#56b6c2")
  '(org-level-6 :inherit variable-pitch :weight normal :height 1.03 :foreground "#46d9ff")
  '(org-level-7 :inherit variable-pitch :weight normal :height 1.02 :foreground "#ff6c6b")
  '(org-level-8 :inherit variable-pitch :weight normal :height 1.01 :foreground "#9098a0")
  '(org-document-title :inherit variable-pitch :weight bold :height 1.5 :underline t)
  '(org-quote :inherit variable-pitch :slant italic :foreground "#7f8c98"))


;; habit tracking module
(use-package! org-habit
  :after org
  :config
  (setq org-habit-show-all-today t))

;; agenda
(after! org-agenda
  (org-super-agenda-mode 1))

;; org-roam settings
org-roam-directory (file-truename "~/org/roam")

(defun my/org-insert-date-keyword ()
    (org-roam-set-keyword "date" (format-time-string "[%Y-%m-%d %a]" (current-time))))

(add-hook 'org-roam-capture-new-node-hook #'my/org-insert-date-keyword)

;; org settings
(after! org
  (setq org-directory (file-truename "~/org/")
        org-agenda-files '("~/org/inbox.org" "~/org/journal.org" "~/org/personal.org" "~/org/sirius.org" "~/work.org")
        org-archive-location "~/org/archive/%s_archive.org::"

        ;; enable logging of done tasks, and log stuff into the LOGBOOK drawer
        org-log-done t
        org-log-into-drawer t

        ;; refile between both files (and to project headings)
        org-refile-targets '((org-agenda-files :maxlevel . 2))
        org-refile-use-outline-path 'file
        org-refile-allow-creating-parent-nodes 'confirm

        ;; aesthetics & layout
        org-columns-default-format "%50TODO %ITEM(Task) %Effort(Effort){:} %Link(Link)"
        org-agenda-span 7
        org-agenda-prefix-format " %i %-18:c%-12t %-10s"
        org-agenda-current-time-string "ᐊ┈┈┈┈┈┈┈ Now"
        org-agenda-time-grid '((today require-timed remove-match)
                               (0900 1200 1400 1700 2100)
                               "      "
                               "┈┈┈┈┈┈┈┈┈┈┈┈┈")
        org-agenda-deadline-leaders
        '("TODAY " "In %d d. " "%d d. ago "))

  (setq org-agenda-format-date
        (lambda (date)
          (concat "\n"
                  (org-agenda-format-date-aligned date))))

  (setq org-super-agenda-groups
        '((:name "⚡ Overdue"
           :and (:deadline past :not (:todo "DONE"))
           :order 0)
          (:name "📌 Today"
           :and (:scheduled today :not (:todo "DONE"))
           :order 1)
          (:name "📋 Projects"
           :auto-parent t
           :order 2)
          (:discard (:todo ("DONE" "STOP")))))

  (setq org-agenda-custom-commands
      `(("g" "Get Things Done!"
         ((agenda ""
                  ((org-agenda-overriding-header "WORK - Yesterday / Today / Tomorrow\n")
                   (org-agenda-files '("~/org/work.org"))
                   (org-agenda-start-day "-1d")
                   (org-agenda-start-on-weekday nil)
                   (org-agenda-span 3)
                   (org-agenda-sorting-strategy '(deadline-up priority-down))
                   (org-super-agenda-groups '((:auto-parent))
                    '((:name "⚡ Overdue"
                       :and (:deadline past :not (:todo "DONE"))
                       :order 0
                       (:auto-parent))
                      (:name "📌 Today"
                       :and (:scheduled today :not (:todo "DONE"))
                       :order 1
                       (:auto-parent))
                      (:name "📋 Tasks"
                       :order 2
                       (:auto-category)
                       (:auto-parent))
                      ))))

          (agenda ""
                  ((org-agenda-overriding-header "SIRIUS - Weekly\n")
                   (org-agenda-files '("~/org/sirius.org"))
                   (org-agenda-span 'week)
                   (org-agenda-sorting-strategy '(deadline-up priority-down))
                   (org-super-agenda-groups '((:auto-parent))
                    '((:name "⚡ Overdue"
                       :and (:deadline past :not (:todo "DONE"))
                       :order 0
                       (:auto-parent))
                      (:name "📌 Today"
                       :and (:scheduled today :not (:todo "DONE"))
                       :order 1
                       (:auto-parent))
                      (:name "📋 Tasks"
                       :order 2
                       (:auto-category)
                       (:auto-parent))
                      ))))

          (agenda ""
                  ((org-agenda-overriding-header "PERSONAL - Weekly\n")
                   (org-agenda-files '("~/org/personal.org"))
                   (org-agenda-span 'week)
                   (org-agenda-sorting-strategy '(deadline-up priority-down))
                   (org-super-agenda-groups '((:auto-parent))
                    '((:name "⚡ Overdue"
                       :and (:deadline past :not (:todo "DONE"))
                       :order 0
                       (:auto-parent))
                      (:name "📌 Today"
                       :and (:scheduled today :not (:todo "DONE"))
                       :order 1
                       (:auto-parent))
                      (:name "📋 Tasks"
                       :order 2
                       (:auto-category)
                       (:auto-parent))
                      ))))
        ))))

  ;; custom workflow state
  (setq org-todo-keywords
        '((sequence
           "TODO(t!)"                    ; Actionable item
           "NEXT(n)"                     ; Immediate next action
           "WIP(i)"                      ; Work in progress
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

  ;; keyword colors
  (setq org-todo-keyword-faces
        '(("NEXT" . +org-todo-active)
          ("WIP" . +org-todo-project)
          ("HOLD" . +org-todo-onhold)
          ("PROJ" . +org-todo-project)
          ("WAIT" . +org-todo-onhold)
          ("STOP" . +org-todo-cancel)))

  ;; clocking & history setup
  (setq org-clock-persist 'history
        org-agenda-start-with-log-mode t)

  (org-clock-persistence-insinuate)

  ;; capture headings
  (defun my/org-capture-to-heading (heading)
    "Prompt for a heading matching HEADING (e.g. \"Tasks\", \"Notes\") across all org files."
    (let ((org-refile-targets
           `(("~/org/work.org"      :regexp . ,heading)
             ("~/org/personal.org"  :regexp . ,heading)
             ("~/org/sirius.org"    :regexp . ,heading)
             ("~/org/inbox.org"     :regexp . ,heading))))
      (org-refile-get-location (format "%s to: " heading) nil t)
      (org-refile t nil nil (format "%s to: " heading))))

  ;; org capture templates
  (setq org-capture-templates
        (doct
         '(("Tasks"
            :keys "t"
            :prepend t
            :template("* TODO %^{Description}"
                      "DEADLINE: %^{Deadline}t"
                      ":PROPERTIES:"
                      ":Created: %U"
                      ":Link: %^{Link}A"
                      ":END:"
                      "%?")
            :children (("Inbox"        :keys "1" :headline "Tasks"               :file "~/org/inbox.org")
                       ("Valley Metro" :keys "2" :olp("Valley Metro" "Tasks")    :file "~/org/work.org")
                       ("Access Legal" :keys "3" :olp("Access Legal" "Tasks")    :file "~/org/work.org")
                       ("Juiced"       :keys "4" :olp("Juiced" "Tasks")          :file "~/org/work.org")
                       ("Other Work"   :keys "5" :olp("Other" "Tasks")           :file "~/org/work.org")
                       ("Sirius"       :keys "9" :headline "Tasks"               :file "~/org/sirius.org")
                       ("Personal"     :keys "0" :headline "Tasks"               :file "~/org/personal.org")))

           ("Notes"
            :keys "n"
            :template ("* %?"
                       ":PROPERTIES:"
                       ":Created: %U"
                       ":Context: %a"
                       ":END:")
            :children (("Inbox"        :keys "1" :headline "Notes"              :file "~/org/inbox.org")
                       ("Valley Metro" :keys "2" :olp("Valley Metro" "Notes")    :file "~/org/work.org")
                       ("Access Legal" :keys "3" :olp("Access Legal" "Notes")    :file "~/org/work.org")
                       ("Juiced"       :keys "4" :olp("Juiced" "Notes")          :file "~/org/work.org")
                       ("Other Work"   :keys "5" :olp("Other" "Notes")           :file "~/org/work.org")
                       ("Sirius"       :keys "9" :headline "Notes"               :file "~/org/sirius.org")
                       ("Personal"     :keys "p" :headline "Notes"              :file "~/org/personal.org")))

        )))

) ;; after! org
