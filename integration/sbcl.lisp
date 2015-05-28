;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package "COM.INFORMATIMAGO.COMMON-LISP.SOURCE-TEXT")

(defun enable-shebang-syntax (&optional (readtable source-text:*source-readtable*))
  (reader:set-dispatch-macro-character #\# #\!
                                       (lambda (s c n)
                                         (declare (ignore n))
                                         (swank/sbcl::shebang-reader s c nil))
                                       readtable))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun sbcl-version>= (&rest args)
    (if (sb-impl::version>= (sb-impl::split-version-string (lisp-implementation-version))
                            args)
        '(:and)
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
