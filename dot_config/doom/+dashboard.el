;;; lisp/dashboard.el -*- lexical-binding: t; -*-

(setq +dashboard-menu-sections
      (cl-subseq +dashboard-menu-sections 2 5))

(setq +dashboard-functions
      `(+dashboard-widget-banner
        +dashboard-widget-shortmenu
        +dashboard-widget-footer))
