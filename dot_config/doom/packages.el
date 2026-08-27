;;; $DOOMDIR/packages.el -*- lexical-binding: t; no-byte-compile: t -*-

;; ui
(package! spacious-padding)
(package! dirvish)
(package! ultra-scroll :recipe (:host github :repo "jdtsmith/ultra-scroll"))

;; coding
(package! aggressive-indent)

;; org-mode
(package! doct)
(package! org-super-agenda)
(package! org-roam-ui)
(package! org-rich-yank)

;; logs
(package! logview)

;; agents
(package! pi-coding-agent)
(package! shell-maker)
(package! acp)
(package! agent-shell)

;; vcs
(package! orgit)
(package! vc-jj)
(package! jj-mode :recipe (:host github :repo "bolivier/jj-mode.el"))
(package! git-link :recipe (:host github :repo "sshaw/git-link"))
(package! majutsu :recipe (:host github :repo "0WD0/majutsu"))

;; chordpro
(package! chordpro-mode)

;; terminal
(use-package evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))
