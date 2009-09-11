;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package "COM.INFORMATIMAGO.COMMON-LISP.SOURCE-TEXT")

(defmethod hu.dwim.walker::find-walker-handler ((instance source-list))
  (hu.dwim.walker::find-walker-handler (source-object-form instance)))

(defmethod hu.dwim.walker::find-walker-handler ((instance source-symbol))
  (hu.dwim.walker::find-walker-handler (source-symbol-value instance)))

(defmethod hu.dwim.walker::find-walker-handler ((instance source-number))
  (hu.dwim.walker::find-walker-handler (source-number-value instance)))

(defmethod hu.dwim.walker::find-walker-handler :around ((instance source-object))
  (lambda (&rest args)
    (setf (source-object-form instance) (apply (call-next-method) args))))

;; TODO: there is already a defgene
(defmethod hu.dwim.walker::coerce-to-form ((instance cons))
  instance)

(defmethod hu.dwim.walker::coerce-to-form ((instance source-symbol))
  (source-symbol-value instance))

(defmethod hu.dwim.walker::coerce-to-form ((instance source-number))
  (source-number-value instance))

(defmethod hu.dwim.walker::coerce-to-form ((instance source-quote))
  (list 'quote (source-object-subform instance)))

(defmethod hu.dwim.walker::coerce-to-form ((instance source-list))
  (remove-if (lambda (element)
               (typep element 'source-whitespace))
             (source-sequence-elements instance)))

;; TODO: rename or what?
(defun source-xxx (text)
  (let ((instance (source-read-from-string text nil text nil t)))
    (source-form instance)
    (hu.dwim.walker:walk-form instance)
    instance))
