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
                                         (swank-backend::shebang-reader s c nil))
                                       readtable))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun sbcl-version>= (&rest subversions)
    (values (ignore-errors (apply #'sb-ext:assert-version->= subversions) t))))

;; the incompatible change: https://github.com/sbcl/sbcl/commit/d7265bc05d7c3ba83194cb80b3371a54d3c136e4
;; released with sbcl 1.2.2
(defmethod %source-form ((instance source-backquote))
  (if (sbcl-version>= 1 2 2)
      (cons (intern #.(string '#:quasiquote) #.(find-package '#:sb-int)) (%source-form (source-object-subform instance)))
      (cons (intern #.(string '#:backq-list) #.(find-package '#:sb-impl))
            (mapcar (lambda (form)
                      (if (and (consp form)
                               (symbolp (first form))
                               (eq (symbol-package (first form)) #.(find-package '#:sb-impl))
                               (equal (symbol-name (first form)) #.(string '#:backq-comma)))
                          (cdr form)
                          (list 'quote form)))
                    (%source-form (source-object-subform instance))))))

(defmethod %source-form ((instance source-unquote))
  (if (sbcl-version>= 1 2 2)
      (funcall (intern #.(string '#:unquote) #.(find-package '#:sb-impl)) (%source-form (source-object-subform instance)))
      (cons (intern #.(string '#:backq-comma) #.(find-package '#:sb-impl))
            (%source-form (source-object-subform instance)))))
