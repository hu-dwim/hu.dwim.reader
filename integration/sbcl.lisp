;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package "COM.INFORMATIMAGO.COMMON-LISP.SOURCE-TEXT")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun if-symbol-exists (package name)
    "Can be used to conditionalize at read-time like this: #+#.(hu.dwim.util:if-symbol-exists \"PKG\" \"FOO\")(pkg::foo ...)"
    (if (and (find-package (string package))
             (find-symbol (string name) (string package)))
        '(:and)
        '(:or))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun sbcl-version>= (&rest subversions)
    (declare (ignorable subversions))
    (or #+#.(source-text::if-symbol-exists '#:sb-ext '#:assert-version->=)
        (values (ignore-errors (apply #'sb-ext:assert-version->= subversions) '(:and)))
        '(:or))))

;; FTR, the incompatible change that was released with 1.2.2:
;; https://github.com/sbcl/sbcl/commit/d7265bc05d7c3ba83194cb80b3371a54d3c136e4
(defmethod %source-form ((instance source-backquote))
  ;; damn, a simple readtime conditional is painful without FEATURE-COND (from hu.dwim.syntax-sugar)
  #+#.(source-text::sbcl-version>= 1 2 2)
  (cons 'sb-int:quasiquote (%source-form (source-object-subform instance)))
  #-#.(source-text::sbcl-version>= 1 2 2)
  (cons 'sb-impl::backq-list (mapcar (lambda (form)
                                       (if (and (consp form)
                                                (eq 'sb-impl::backq-comma (first form)))
                                           (cdr form)
                                           (list 'quote form)))
                                     (%source-form (source-object-subform instance)))))

(defmethod %source-form ((instance source-unquote))
  #+#.(source-text::sbcl-version>= 1 2 2)
  (sb-int:unquote (%source-form (source-object-subform instance)))
  #-#.(source-text::sbcl-version>= 1 2 2)
  (cons 'sb-impl::backq-comma (%source-form (source-object-subform instance))))
