;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(defsystem :hu.dwim.reader
  :defsystem-depends-on (:hu.dwim.asdf)
  :class "hu.dwim.asdf:hu.dwim.system"
  :description "Whitespace preserving Common Lisp reader."
  :components ((:module "source"
                :components ((:file "reader" :depends-on ("source-form"))
                             (:file "source-form")
                             (:file "source-text" :depends-on ("reader"))))))
#+sbcl
(defsystem :hu.dwim.reader+sbcl
  :defsystem-depends-on (:hu.dwim.asdf)
  :class "hu.dwim.asdf:hu.dwim.system"
  :depends-on (:hu.dwim.reader
               :swank)
  :components ((:module "integration"
                :components ((:file "sbcl")))))

#+sbcl
(defmethod perform :after ((operation load-op) (system (eql (find-system :hu.dwim.reader))))
  (load-system :hu.dwim.reader+sbcl))
