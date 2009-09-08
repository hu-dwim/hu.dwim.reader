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
                                       readtable))
