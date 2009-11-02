;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package "COM.INFORMATIMAGO.COMMON-LISP.SOURCE-TEXT")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (import '(hu.dwim.def:def
            hu.dwim.def:layered-method
            hu.dwim.def:layered-methods
            hu.dwim.walker::find-walker-handler
            hu.dwim.walker::coerce-to-form
            )))

(def layered-methods find-walker-handler
  (:method ((instance source-list))
    (find-walker-handler (source-object-form instance)))
  (:method ((instance source-symbol))
    (find-walker-handler (source-symbol-value instance)))
  (:method ((instance source-number))
    (find-walker-handler (source-number-value instance)))
  (:method :around ((instance source-object))
    (lambda (&rest args)
      (setf (source-object-form instance) (apply (call-next-method) args)))))

(def layered-methods coerce-to-form
  (:method ((instance cons))
    instance)
  (:method ((instance source-symbol))
    (source-symbol-value instance))
  (:method ((instance source-number))
    (source-number-value instance))
  (:method ((instance source-quote))
    (list 'quote (source-object-subform instance)))
  (:method ((instance source-list))
    (remove-if (lambda (element)
                 (typep element 'source-whitespace))
               (source-sequence-elements instance))))

;; TODO: rename or what?
(defun source-xxx (text)
  (let ((instance (source-read-from-string text nil text nil t)))
    (source-form instance)
    (hu.dwim.walker:walk-form instance)
    instance))
