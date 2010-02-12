;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package "COM.INFORMATIMAGO.COMMON-LISP.SOURCE-TEXT")

(defclass source-boolean (source-object)
  ((value     :accessor source-boolean-value
              :initarg :value)))
(export 'source-boolean)

(defun enable-sharp-boolean-syntax (&optional (readtable source-text:*source-readtable*))
  (reader:set-dispatch-macro-character #\# #\t
                                       (lambda (&rest args)
                                         (declare (ignore args))
                                         (building-source-object *stream* *start* 'source-boolean :value t))
                                       readtable)
  (reader:set-dispatch-macro-character #\# #\f
                                       (lambda (&rest args)
                                         (declare (ignore args))
                                         (building-source-object *stream* *start* 'source-boolean :value nil))
                                       readtable)
  readtable)

(defmethod %source-form ((instance source-boolean))
  (source-boolean-value instance))

;; TODO: depends on walker
#+nil
(defmethod describe-source-form ((form constant-form) (instance source-boolean))
  (if (source-boolean-value instance)
      "boolean constant true"
      "boolean constant false"))
