;;; agenda.el -*- lexical-binding: t; -*-

(setq org-agenda-files (list "~/org"))

;; Refile between both files (and to project headings)
(setq org-refile-targets '((org-agenda-files :maxlevel . 2)))
(setq org-refile-use-outline-path 'file)
(setq org-refile-allow-creating-parent-nodes 'confirm)

;; Archiving: send done tasks to archive files
(setq org-archive-location "~/org/archive/%s_archive.org::")

;; Column default format
(setq org-columns-default-format "%50TODO %ITEM(Task) %Effort(Effort){:} %Link(Link)")

;; Calendar Aesthetics & Layouts
  (setq org-agenda-span 7
        org-agenda-prefix-format " %i %-18:c%-12t %-10s"
        org-agenda-current-time-string "ᐊ┈┈┈┈┈┈┈ Now"
        org-agenda-time-grid '((today require-timed remove-match)
                               (0900 1200 1400 1700 2100)
                               "      "
                               "┈┈┈┈┈┈┈┈┈┈┈┈┈"))

(setq org-agenda-deadline-leaders
      '("TODAY " "In %d d. " "%d d. ago "))

;; AGENDAS
(setq org-agenda-custom-commands
      `(("g" "Get Things Done!"
         ((agenda ""
                  ((org-agenda-overriding-header "WORK - Yesterday / Today / Tomorrow\n")
                   (org-agenda-files '("~/org/todo-work.org"))
                   (org-agenda-start-day "-1d")
                   (org-agenda-start-on-weekday nil)
                   (org-agenda-span 3)
                   (org-agenda-sorting-strategy '(deadline-up priority-down))))
          (agenda ""
                  ((org-agenda-overriding-header "PERSONAL - Weekly\n")
                   (org-agenda-files '("~/org/todo-personal.org"))
                   (org-agenda-span 'week)
                   (org-agenda-sorting-strategy '(deadline-up priority-down))))
        ))))
