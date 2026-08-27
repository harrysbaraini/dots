;;; lisp/projects.el -*- lexical-binding: t; -*-

;; Automatically discover projects
(after! projectile
  (setq projectile-project-search-path
        '(("~/Projects" . 3)))
  (setq projectile-auto-discover t
        projectile-auto-cleanup-known-projects t))

(defun my/project-root ()
  "Return the root directory of the current project."
  (or (and (fboundp 'projectile-project-root)
           (projectile-project-root))
      (when-let ((project (project-current nil)))
        (project-root project))
      (user-error "This buffer is not inside a recognised project")))

(defun my/project-org-file ()
  "Return the path to project.org for the current project."
  (expand-file-name "project.org" (my/project-root)))

(defun my/project-ensure-org-file ()
  "Create project.org from a starter template when it does not exist."
  (let ((file (my/project-org-file))
        (title (file-name-nondirectory
                (directory-file-name (my/project-root)))))
    (unless (file-exists-p file)
      (with-temp-file file
        (insert (format "#+title: %s\n\n" title))
        (insert "* Context\n")
        (insert ":PROPERTIES:\n")
        (insert ":BROWSER_APP: Dia\n")
        (insert ":BROWSER_PROFILE: \n")
        (insert ":BROWSER_URL: \n")
        (insert ":END:\n\n")
        (insert "* Links\n")
        (insert "- [[https://example.com][Example web link]]\n\n")
        (insert "* Slack\n")
        (insert "- [[slack://channel?team=T01234567&id=C01234567][#example-channel]]\n\n")
        (insert "* Notes\n")))
    file))

(defun my/project-open-notes ()
  "Open the current project's project.org, creating it if necessary."
  (interactive)
  (find-file (my/project-ensure-org-file)))

(defun my/project-context-property (property)
  "Read PROPERTY from the Context heading in the current project's project.org."
  (let ((file (my/project-ensure-org-file)))
    (with-current-buffer (find-file-noselect file)
      (org-mode)
      (save-excursion
        (goto-char (point-min))
        (unless (re-search-forward "^\\*+ Context\\s-*$" nil t)
          (user-error "No * Context heading in %s" file))
        (org-back-to-heading t)
        (or (org-entry-get nil property t)
            (user-error "No %s property in Context" property))))))

(defun my/project-links-under-heading (heading)
  "Return Org links under HEADING in the current project's project.org."
  (let ((file (my/project-ensure-org-file)))
    (with-current-buffer (find-file-noselect file)
      (org-mode)
      (save-excursion
        (goto-char (point-min))
        (unless (re-search-forward
                 (format "^\\*+ %s\\s-*$" (regexp-quote heading)) nil t)
          (user-error "No * %s heading in %s" heading file))
        (org-back-to-heading t)
        (save-restriction
          (org-narrow-to-subtree)
          (let (links)
            (org-element-map (org-element-parse-buffer) 'link
              (lambda (link)
                (let* ((url (org-element-property :raw-link link))
                       (begin (org-element-property :contents-begin link))
                       (end (org-element-property :contents-end link))
                       (label (if (and begin end)
                                  (buffer-substring-no-properties begin end)
                                url)))
                  (push (cons label url) links))))
            (nreverse links)))))))

(defun my/project-open-link-from-heading (heading)
  "Prompt for and open a link beneath HEADING in project.org."
  (let* ((links (my/project-links-under-heading heading))
         (name (completing-read (format "%s: " heading)
                                (mapcar #'car links) nil t))
         (url (cdr (assoc name links))))
    (org-link-open-from-string (format "[[%s]]" url))))

(defun my/project-links ()
  "Choose a link from the current project's Links heading."
  (interactive)
  (my/project-open-link-from-heading "Links"))

(defun my/project-open-slack ()
  "Choose a Slack channel from the current project's Slack heading."
  (interactive)
  (my/project-open-link-from-heading "Slack"))

(defun my/project-open-browser ()
  "Open the current project's default URL using its Dia profile."
  (interactive)
  (let ((app (my/project-context-property "BROWSER_APP"))
        (profile (my/project-context-property "BROWSER_PROFILE"))
        (url (my/project-context-property "BROWSER_URL")))
    (unless (and (not (string-empty-p profile))
                 (not (string-empty-p url)))
      (user-error "Set BROWSER_PROFILE and BROWSER_URL in project.org"))
    ;; Change this if Dia uses a different profile command-line option.
    (start-process "project-browser" nil
                   "open" "-na" app "--args"
                   (format "--profile-directory=%s" profile)
                   url)))

(map! :leader
      :prefix ("p m" . "project context")
      "n" #'my/project-open-notes
      "l" #'my/project-links
      "s" #'my/project-open-slack
      "b" #'my/project-open-browser)

;; Automatically open recent file when opening a project
;; (after! projectile
;;   (defun my/projectile-open-most-recent ()
;;     "Open the most recently visited file in the current project.
;; If there is no recent file (e.g. first visit), fall back to `projectile-find-file'."
;;     (let ((recent (car (projectile-recentf-files))))
;;       (if (and recent (file-exists-p recent))
;;           (find-file recent)
;;         (projectile-find-file))))

;;   (setq projectile-switch-project-action #'my/projectile-open-most-recent))

;; (after! projectile
;;   (setq projectile-switch-project-action #'projectile-recentf))

(defvar +workspaces-main "todo")
(defvar +workspaces-switch-project-function #'magit-status)

;; =============================================================================
;; 1. ENVIRONMENT & DIRENV INTERACTION
;; =============================================================================
(after! envrc
  (setq envrc-debug nil))

;; =============================================================================
;; 2. LSP-MODE, ISOLATION BOUNDARIES & PHPANTOM REGISTER
;; =============================================================================
(after! lsp-mode
  ;; Force LSP to look up binaries natively via the project's local PATH (via direnv)
  (setq lsp-client-path-options nil)
  (setq lsp-before-initialize-hook nil)

  ;; DICTATE MULTI-PROJECT SAFETY BOUNDARIES:
  ;; Disabling auto-guess forces lsp-mode to interactively prompt you when hitting
  ;; a new folder boundary instead of making unsafe assumptions about your layout.
  (setq lsp-auto-guess-root t)
  (setq lsp-nested-project-root-selection 'local))

  ;; =============================================================================
;; 3. SIDEBAR (TREEMACS) CONFIGURATION
;; =============================================================================
(after! treemacs
  ;; Ensure the sidebar intelligently tracks and focuses the file you are editing
  (setq treemacs-follow-mode t)
  (setq treemacs-project-follow-mode t)

  ;; Optional: Force Treemacs to remember your open workspaces across sessions
  (setq treemacs-persist-file (concat doom-cache-dir "treemacs-persist"))
  (setq treemacs-last-error-persist-file (concat doom-cache-dir "treemacs-persist-errors")))
