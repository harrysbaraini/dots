;;; +org.el -*- lexical-binding: t; -*-

(defconst my/org-root
  (file-name-as-directory (file-truename "~/org")))
(defconst my/org-inbox-file
  (expand-file-name "inbox.org" my/org-root))
(defconst my/org-tasks-directory
  (file-name-as-directory (expand-file-name "tasks" my/org-root)))
(defconst my/org-personal-file
  (expand-file-name "personal.org" my/org-tasks-directory))
(defconst my/org-task-files
  (list my/org-personal-file))
(defconst my/org-archive-directory
  (file-name-as-directory (expand-file-name "archive" my/org-root)))
(defconst my/org-roam-directory
  (file-name-as-directory (expand-file-name "roam" my/org-root)))
(defconst my/org-roam-notes-directory
  (file-name-as-directory (expand-file-name "notes" my/org-roam-directory)))
(defconst my/org-roam-dailies-directory
  (file-name-as-directory (expand-file-name "daily" my/org-roam-directory)))

(setq org-directory my/org-root)

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

(defface my/org-agenda-category
  '((default
             :height 1.0
             :width normal
             :weight semi-bold
             :underline nil)
    (((background light)) :foreground "black")
    (t :foreground "white"))
  "Face for category badges in Org agenda views.")

(defface my/org-agenda-tag
  '((t (:inherit shadow
        :height 0.8
        :weight normal
        :background unspecified
        :box nil
        :inverse-video nil)))
  "Face for plain tags at the right edge of Org agenda views.")

(defface my/org-agenda-tree-indicator
  '((t (:inherit shadow
        :weight normal
        :background unspecified
        :box nil)))
  "Face for task hierarchy indicators in Org agenda views.")

(defun my/org-agenda-category-badge (category)
  "Render CATEGORY as a badge in a fixed-width agenda field."
  (let* ((name (substring-no-properties (format "%s" (or category ""))))
         (label (truncate-string-to-width name 14 nil nil "…")))
    (if (string-empty-p label)
        (make-string 16 ?\s)
      (let* ((badge (propertize (format " %s " label)
                                'face 'my/org-agenda-category))
             (padding (max 0 (- 16 (string-width badge)))))
        (concat badge (make-string padding ?\s))))))

(defvar time)
(defvar extra)

(defun my/org-agenda-deadline-today-p ()
  "Return non-nil when the current entry deadline falls today."
  (when-let ((deadline (org-entry-get nil "DEADLINE")))
    (= (time-to-days (org-time-string-to-time deadline))
       (org-today))))

(defun my/org-agenda-deadline-date ()
  "Return the current entry deadline as a short date string."
  (when-let ((deadline (org-entry-get nil "DEADLINE")))
    (format-time-string "%d %b %Y"
                        (org-time-string-to-time deadline))))

(defun my/org-agenda-when-field ()
  "Return one fixed-width time/planning field for an agenda item."
  (let* ((raw (string-trim
               (if (string-empty-p time)
                   (or extra "")
                 time)))
         (value (if (and (string= raw "TODAY")
                         (not (my/org-agenda-deadline-today-p)))
                    (or (my/org-agenda-deadline-date) raw)
                  raw))
         (label (truncate-string-to-width value 20 nil nil "…")))
    ;; A trailing `%t' in the prefix keeps Org's native time extraction
    ;; enabled.  Clear it here so that it is not rendered a second time.
    (setq time "")
    (concat label (make-string (max 0 (- 20 (string-width label))) ?\s))))


(use-package! org-habit
  :after org
  :config
  (setq org-habit-show-all-today t))

(after! org
  (require 'doct)

  (defun my/org-capture-task-default-deadline-time ()
    "Set the task deadline prompt's default time to 10:00 AM."
    (let* ((default-time (or org-overriding-default-time (current-time)))
           (decoded (decode-time default-time)))
      (setq-local org-overriding-default-time
                  (encode-time 0 0 10
                               (nth 3 decoded)
                               (nth 4 decoded)
                               (nth 5 decoded)
                               (nth 8 decoded)))))

  (setq org-agenda-files my/org-task-files
        org-default-notes-file my/org-inbox-file
        org-archive-location (concat my/org-archive-directory "%s::")

        org-hide-emphasis-markers t
        org-ellipsis " …"
        org-hide-leading-stars t
        org-startup-indented t

        org-log-done t
        org-log-into-drawer t
        org-clock-persist 'history

        org-use-tag-inheritance t
        org-agenda-remove-tags t
        org-agenda-tags-column 0
        org-tags-column 0

        org-refile-targets `((,my/org-inbox-file :maxlevel . 3)
                             (org-agenda-files :maxlevel . 3))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm

        org-todo-keywords
        '((sequence
           "TODO(t)" "NEXT(n)" "DOIN(g)" "WAIT(w@/!)" "HOLD(h@/!)"
           "|" "DONE(d!)" "CANC(c@)")
          (sequence "PROJ(p)" "|" "DONE(d!)" "CANC(c@)"))
        org-todo-keyword-faces
        '(("NEXT" . +org-todo-active)
          ("DOIN" . +org-todo-project)
          ("WAIT" . +org-todo-onhold)
          ("HOLD" . +org-todo-onhold)
          ("PROJ" . +org-todo-project)
          ("CANC" . +org-todo-cancel))
        org-highest-priority ?A
        org-default-priority ?B
        org-lowest-priority ?C

        org-columns-default-format "%50TODO %ITEM(Task) %Effort(Effort){:} %Link(Link)"
        org-agenda-todo-keyword-format "%-4s"
        org-agenda-prefix-format
        '((agenda . " %i %(my/org-agenda-category-badge category)%(my/org-agenda-when-field)%t    ")
          (todo . " %i %(my/org-agenda-category-badge category)%(my/org-agenda-when-field)%t    ")
          (tags . " %i %(my/org-agenda-category-badge category)%(my/org-agenda-when-field)%t    ")
          (search . " %i %(my/org-agenda-category-badge category)%(my/org-agenda-when-field)%t    "))
        org-agenda-current-time-string "---------------- Now"
        org-agenda-time-grid '((today require-timed remove-match)
                               (0900 1200 1400 1700 2100)
                               ""
                               "----------------")
        org-agenda-deadline-leaders '("TODAY " "In %d d. " "%d d. ago ")
        org-agenda-start-with-log-mode t
        org-agenda-log-mode-items '(closed clock state))

  (setq org-agenda-format-date
        (lambda (date)
          (concat "\n" (org-agenda-format-date-aligned date))))

  (setq org-capture-templates
        (doct
         `(("Inbox"
            :keys "i"
            :file ,my/org-inbox-file
            :headline "Inbox"
            :prepend t
            :template ("* %^{Title}"
                       ":PROPERTIES:"
                       ":CREATED: %U"
                       ":END:"
                       "%a"
                       "%?"))

           ("Task"
            :keys "t"
            :prepend t
            :hook my/org-capture-task-default-deadline-time
            :template ("* TODO [#B] %^{Task}"
                       "DEADLINE: %^{Deadline}T"
                       ":PROPERTIES:"
                       ":CREATED: %U"
                       ":END:"
                       "%a"
                       "%?")
            :children
            (("Personal" :keys "p" :file ,my/org-personal-file :headline "Tasks")
             ("Family"   :keys "f" :file ,my/org-personal-file :headline "Family")
             ("Health"   :keys "h" :file ,my/org-personal-file :headline "Health")
             ("Work"     :keys "w" :file ,my/org-personal-file :headline "Work")))

           ("Note"
            :keys "n"
            :prepend t
            :template ("* %^{Title} %{capture-tags}"
                       ":PROPERTIES:"
                       ":CREATED: %U"
                       ":END:"
                       "%a"
                       "%?")
            :children
            (("Personal"
              :keys "p"
              :file ,my/org-inbox-file
              :olp ("Notes" "Personal")
              :capture-tags ":personal:")
             ("General"
              :keys "g"
              :file ,my/org-inbox-file
              :olp ("Notes" "General")
              :capture-tags ":general:"))))))

  (org-clock-persistence-insinuate))

(defun my/org-roam-dailies-capture-journal ()
  "Capture a journal entry in today's Org-roam daily note."
  (interactive)
  (org-roam-dailies-capture-today nil "j"))

(map! :leader
      :desc "Journal today" "n j" #'my/org-roam-dailies-capture-journal)

(after! org-roam
  (setq org-roam-directory my/org-roam-directory
        org-roam-extract-new-file-path "notes/%<%Y%m%d%H%M%S>-${slug}.org"
        org-roam-capture-templates
        '(("p" "Personal" plain "%?"
           :target (file+head "notes/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :personal:\n")
           :unnarrowed t)
          ("g" "General" plain "%?"
           :target (file+head "notes/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :general:\n")
           :unnarrowed t))
        org-roam-dailies-directory "daily/"
        org-roam-dailies-capture-templates
        '(("j" "Journal" entry "* %<%H:%M> %?"
           :target (file+head+olp "%<%Y-%m-%d>.org"
                                  "#+title: %<%Y-%m-%d>\n#+date: %u\n"
                                  ("Journal")))
          ("n" "Daily note" entry "* %<%H:%M> %?"
           :target (file+head+olp "%<%Y-%m-%d>.org"
                                  "#+title: %<%Y-%m-%d>\n#+date: %u\n"
                                  ("Notes")))
          ("l" "Activity log" entry "* %<%H:%M> %?"
           :target (file+head+olp "%<%Y-%m-%d>.org"
                                  "#+title: %<%Y-%m-%d>\n#+date: %u\n"
                                  ("Log"))))))


(defun my/org-agenda-hide-state-log-prefix-a (args)
  "Remove redundant state text from logged agenda entries."
  (when (and (stringp (car args))
             (string-prefix-p "State:" (car args)))
    (setcar args ""))
  args)

(after! org-agenda
  (advice-remove #'org-agenda-format-item #'my/org-agenda-hide-state-log-prefix-a)
  (advice-add #'org-agenda-format-item
              :filter-args #'my/org-agenda-hide-state-log-prefix-a))

(defun my/org-agenda-task-child-p (marker)
  "Return non-nil when MARKER's heading descends from another task."
  (and (markerp marker)
       (marker-buffer marker)
       (org-with-point-at marker
         (org-back-to-heading t)
         (catch 'task-parent
           (while (org-up-heading-safe)
             (when (org-get-todo-state)
               (throw 'task-parent t)))
           nil))))

(defun my/org-agenda-render-task-tree-h ()
  "Indent task descendants and render their agenda tree indicators."
  (let ((inhibit-read-only t))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (let* ((line-start (line-beginning-position))
               (line-end (line-end-position))
               (marker (get-text-property line-start 'org-hd-marker))
               (todo-state (get-text-property line-start 'todo-state))
               (state (and todo-state
                           (substring-no-properties
                            (format "%s" todo-state)))))
          (when (and state
                     (not (string-empty-p state))
                     (my/org-agenda-task-child-p marker))
            (goto-char line-start)
            (when (re-search-forward
                   (concat "\\_<" (regexp-quote state) "\\_>")
                   (min line-end (+ line-start 64))
                   t)
              (let ((field-start (- (match-beginning 0) 3)))
                (when (and (>= field-start line-start)
                           (string=
                            (buffer-substring-no-properties
                             field-start (match-beginning 0))
                            "   "))
                  (delete-region field-start (match-beginning 0))
                  (goto-char field-start)
                  (insert
                   (propertize "    ↳ "
                               'face
                               'my/org-agenda-tree-indicator))))))
          (forward-line 1))))))

(defun my/org-agenda-render-tags-h ()
  "Render agenda tags as compact shadow text at the right edge."
  (let ((inhibit-read-only t))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (let* ((line-start (line-beginning-position))
               (tags (get-text-property line-start 'tags)))
          (when tags
            (let* ((text (propertize
                          (mapconcat
                           (lambda (tag) (substring-no-properties tag))
                           tags " ")
                          'face 'my/org-agenda-tag))
                   (align
                    (if (display-graphic-p)
                        `(space :align-to (- right
                                             (,(string-pixel-width text))))
                      `(space :align-to
                              (- right ,(+ 1 (string-width text)))))))
              (goto-char (line-end-position))
              (insert " " (propertize " " 'display align) text)))
          (forward-line 1))))))

(defun my/org-agenda-category-badges-h ()
  "Apply category badge faces after agenda line faces are finalized."
  (let ((inhibit-read-only t))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (let* ((line-start (line-beginning-position))
               (line-end (line-end-position))
               (category (get-text-property line-start 'org-category))
               (label (and category
                           (truncate-string-to-width
                            (substring-no-properties (format "%s" category))
                            14 nil nil "…"))))
          (when (and label
                     (not (string-empty-p label)))
            (goto-char line-start)
            (when (search-forward label (min line-end (+ line-start 24)) t)
              (add-face-text-property
               (max line-start (1- (match-beginning 0)))
               (min line-end (1+ (match-end 0)))
               'my/org-agenda-category)))
          (forward-line 1))))))

(after! org-modern
  (add-hook 'org-agenda-finalize-hook #'my/org-agenda-render-task-tree-h t)
  (add-hook 'org-agenda-finalize-hook #'my/org-agenda-render-tags-h t)
  (add-hook 'org-agenda-finalize-hook #'my/org-agenda-category-badges-h t))

(use-package! org-super-agenda
  :after org-agenda
  :config
  (org-super-agenda-mode 1)

  (setq org-agenda-custom-commands
        '(("d" "Daily: yesterday / today / next 3 days"
           ((agenda ""
                    ((org-agenda-overriding-header "Yesterday / Today / Next 3 Days")
                     (org-agenda-start-day "-1d")
                     (org-agenda-start-on-weekday nil)
                     (org-agenda-span 5)
                     (org-deadline-warning-days 0)
                     (org-agenda-start-with-log-mode t)
                     (org-agenda-log-mode-items '(closed clock state))
                     (org-agenda-sorting-strategy
                      '(time-up deadline-up priority-down todo-state-up))
                     (org-super-agenda-groups
                      '((:name "Completed / changed" :log t :order 90)
                        (:name "Overdue" :deadline past :order 0)
                        (:name "Timed / habits" :time-grid t :habit t :order 10)
                        (:name "Must do" :priority "A" :order 20)
                        (:name "In progress / next" :todo ("NEXT" "DOIN") :order 30)
                        (:name "Waiting / on hold" :todo ("WAIT" "HOLD") :order 40)
                        (:name "Scheduled / remaining" :anything t :order 50)
                        (:discard (:anything t))))))))
          ("w" "Weekly plan by area"
           ((agenda ""
                    ((org-agenda-overriding-header "Next 7 Days")
                     (org-agenda-start-day "0d")
                     (org-agenda-start-on-weekday nil)
                     (org-agenda-span 7)
                     (org-deadline-warning-days 0)
                     (org-agenda-sorting-strategy
                      '(time-up deadline-up priority-down todo-state-up))
                     (org-super-agenda-groups '((:auto-group t)))))
            (todo "NEXT"
                  ((org-agenda-overriding-header "Unscheduled NEXT actions")
                   (org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'scheduled 'deadline))
                   (org-agenda-sorting-strategy
                    '(priority-down todo-state-up category-keep))
                   (org-super-agenda-groups '((:auto-group t))))))
          ("u" "Unscheduled tasks"
           ((todo ""
                  ((org-agenda-overriding-header "Unscheduled tasks")
                   (org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'scheduled 'deadline))
                   (org-agenda-sorting-strategy
                    '(priority-down todo-state-up category-keep))
                   (org-super-agenda-groups '((:auto-group t)))))))))))

(defun my/org-agenda-unscheduled-tasks ()
  "Show TODO entries without scheduled dates or deadlines."
  (interactive)
  (org-agenda nil "u"))

(map! :leader
      :desc "Unscheduled tasks" "n u" #'my/org-agenda-unscheduled-tasks)
