;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package "COM.INFORMATIMAGO.COMMON-LISP.SOURCE-TEXT")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (import '(metabang-bind:bind
            hu.dwim.def:def
            hu.dwim.def:generic
            hu.dwim.def:layered-method
            hu.dwim.def:layered-methods
            hu.dwim.def::-self-
            hu.dwim.walker:walk-form
            hu.dwim.walker::find-walker-handler
            hu.dwim.walker::coerce-to-form
            hu.dwim.walker:free-application-form
            hu.dwim.walker:lambda-function-form
            hu.dwim.walker:constant-form
            hu.dwim.walker:variable-reference-form
            hu.dwim.walker:lexical-variable-reference-form
            hu.dwim.walker:special-variable-reference-form
            hu.dwim.walker:free-variable-reference-form
            hu.dwim.walker:let-form
            hu.dwim.walker:let*-form
            hu.dwim.walker:if-form
            hu.dwim.walker::operator-of
            hu.dwim.walker::walk-form
            hu.dwim.walker::walker-macroexpand-1)))

#+nil
(def layer source-walker ()
  ())

(def layered-method walk-form :around ((instance source-object) &key parent environment)
  (setf (source-object-form instance)
        (contextl:call-next-layered-method (source-object-form instance) :parent parent :environment environment)))

(def layered-methods coerce-to-form
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

(def layered-method walker-macroexpand-1 (form &optional env)
  (bind ((macro-name (coerce-to-form (first form))))
    (if (member macro-name '(when unless)) ;; TODO: other macros interface to define such macro names
        (macroexpand-1 (cons macro-name (cdr form)) env)
        (bind ((ht (make-hash-table))
               (coerced-form (labels ((recurse (form)
                                        (bind ((coerced-form (coerce-to-form form))
                                               (result-form (if (consp coerced-form)
                                                                (cons (recurse (car coerced-form)) (recurse (cdr coerced-form)))
                                                                coerced-form)))
                                          (setf (gethash result-form ht) form)
                                          result-form)))
                               (recurse form))))
          (labels ((recurse (form)
                     (bind ((original-form (gethash form ht)))
                       (or original-form
                           (if (consp form)
                               (cons (recurse (car form)) (recurse (cdr form)))
                               form)))))
            (bind (((:values expansion expanded?) (macroexpand-1 coerced-form env)))
              (values (recurse expansion) expanded?)))))))

(def function source-walk (source)
  (source-form source)
  (walk-form source)
  source)

(def class source-description ()
  ((start :initarg :start :accessor start-of :type integer)
   (end :initarg :end :accessor end-of :type integer)
   (source :initarg :source :accessor source-of :type source-object)
   (description :initarg :description :accessor description-of :type string)))

(def method print-object ((self source-description) stream)
  (if (= (start-of self)
         (end-of self))
      (format stream "[~A] ~A" (start-of self) (description-of self))
      (format stream "[~A..~A] ~A" (start-of self) (end-of self) (description-of self))))

(def class source-description-list ()
  ((descriptions :initarg :descriptions :accessor descriptions-of :type list)))

(def method print-object ((self source-description-list) stream)
  (pprint-logical-block (stream (descriptions-of self))
    (loop
      :for index :from 0
      :for description :in (descriptions-of self)
      :unless (zerop index)
      :do (princ " IN " stream)
      :do (princ description stream))))

(def generic source-describe-form (source form)
  (:method ((form null) source)
    (format nil "whitespace ~S" (source-object-text source)))

  (:method ((form free-application-form) source)
    (format nil "function call to ~A" (source-object-form (operator-of form))))

  (:method ((form lambda-function-form) source)
    "lambda function definition")

  (:method ((form symbol) source)
    (format nil "symbol name ~S" form))

  (:method ((form constant-form) (source source-quote))
    (format nil "quoted constant ~S" (source-object-form (source-object-subform source))))

  (:method ((form constant-form) (source source-symbol))
    (format nil "symbol constant ~S" (source-symbol-value source)))

  (:method ((form constant-form) (source source-number))
    (format nil "number constant ~S" (source-number-value source)))

  (:method ((form constant-form) (source source-string))
    (format nil "string constant ~S" (source-string-value source)))

  (:method ((form constant-form) (source source-function))
    (format nil "function constant ~S" (source-object-form (source-object-subform source))))

  (:method ((form variable-reference-form) (source source-symbol))
    (format nil "variable reference ~S" (source-symbol-value source)))

  (:method ((form lexical-variable-reference-form) (source source-symbol))
    (format nil "lexical variable reference ~S" (source-symbol-value source)))

  (:method ((form special-variable-reference-form) (source source-symbol))
    (format nil "special variable reference ~S" (source-symbol-value source)))

  (:method ((form free-variable-reference-form) (source source-symbol))
    (format nil "free variable reference ~S" (source-symbol-value source)))

  (:method ((form let-form) (source source-list))
    "parallel lexical variable binding")

  (:method ((form let*-form) (source source-list))
    "sequential lexical variable binding")

  (:method ((form if-form) (source source-list))
    "conditional branch")

  (:method ((form list) (source source-list))
    ;; KLUDGE: for variable binding parameter list
    "parameter list"))

(def function source-describe-position (source position)
  (bind ((result ()))
    (map-subforms (lambda (ast)
                    (let* ((start (source-object-position ast))
                           (end (1- (+ start (length (source-object-text ast))))))
                      (when (<= start position end)
                        (push (make-instance 'source-description
                                             :start start
                                             :end end
                                             :source ast
                                             :description (bind ((*package* (find-package :keyword)))
                                                            (source-describe-form (source-object-form ast) ast)))
                              result))))
                  source)
    (make-instance 'source-description-list :descriptions result)))

(def function source-describe (source)
  (sort (remove-duplicates (loop
                             :for position :from 0 :below (length (source-object-text source))
                             :collect (source-describe-position source position))
                           :test (lambda (description-list-1 description-list-2)
                                   (every (lambda (description-1 description-2)
                                            (eq (source-of description-1) (source-of description-2)))
                                          (descriptions-of description-list-1) (descriptions-of description-list-2))))
        (lambda (description-list-1 description-list-2)
          (< (start-of (first (descriptions-of description-list-1)))
             (start-of (first (descriptions-of description-list-2)))))))

(def method source-parent-relative-indent ((parent-form if-form) (parent-source source-list) form source form-index)
  (ecase form-index
    (0 1)
    (1 1)
    (2 4)
    (3 4)))

(def method source-parent-relative-indent ((parent-form free-application-form) (parent-source source-list) form source form-index)
  (+ 2 (length (symbol-name (source-symbol-value (operator-of parent-form))))))

(def method source-insert-newline ((parent-form if-form) (parent-source source-list) form source form-index)
  (when (<= 2 form-index)
    t))

(def method source-insert-newline ((parent-form let-form) (parent-source source-list) form source form-index)
  (unless (= form-index 1)
    t))

;; KLUDGE: for variable binding parameter list
(def method source-insert-newline ((parent-form list) (parent-source source-list) (form list) (source source-list) form-index)
  t)

(def method source-insert-newline ((parent-form free-application-form) (parent-source source-list) (form constant-form) (source source-symbol) form-index)
  (when (and (keywordp (source-symbol-value source))
             (eq (source-object-form (operator-of parent-form)) 'make-instance))
    t))
