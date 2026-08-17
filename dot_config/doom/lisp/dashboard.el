;;; lisp/dashboard.el -*- lexical-binding: t; -*-

;; Dashboard customization
;; 1. Configure the order of your modular layout widgets
(setq +dashboard-functions
      `(+dashboard-widget-banner
        +dashboard-widget-shortmenu
        +dashboard-widget-footer))
