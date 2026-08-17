;;; lisp/clipboard.el -*- lexical-binding: t; -*-

(defun my/evil-delete-without-system-clipboard (original-function &rest args)
  "Run Evil deletions without replacing the system clipboard."
  (let ((interprogram-cut-function nil))
    (apply original-function args)))

(advice-add 'evil-delete :around #'my/evil-delete-without-system-clipboard)
(advice-add 'evil-change :around #'my/evil-delete-without-system-clipboard)

(defun my/evil-cut-to-system-clipboard (beg end)
  "Cut the Visual selection and send it to the system clipboard."
  (interactive "r")
  (unless (use-region-p)
    (user-error "Select text first"))
  (kill-region beg end)
  (evil-normal-state))

(map! :leader
      :desc "Cut selection to system clipboard" "X" #'my/evil-cut-to-system-clipboard)
