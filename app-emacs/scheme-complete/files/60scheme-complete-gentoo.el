
;;; scheme-complete site-lisp configuration

(add-to-list 'load-path "@SITELISP@")
(autoload 'scheme-smart-complete "scheme-complete" nil t)
(autoload 'scheme-complete-or-indent "scheme-complete" nil t)
(autoload 'scheme-get-current-symbol-info "scheme-complete")
(eval-after-load 'scheme
  '(progn (define-key scheme-mode-map "\t" 'scheme-complete-or-indent)))
