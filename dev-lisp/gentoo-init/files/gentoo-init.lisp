(in-package #:cl-user)

(let ((*compile-print* nil)
      (*compile-verbose* nil)
      #+cmu (ext:*gc-verbose* nil))
  (handler-bind ((warning #'muffle-warning))
    (load #p"/usr/share/common-lisp/source/asdf/build/asdf.lisp"
          :print nil :verbose nil)))
