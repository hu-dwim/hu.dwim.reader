;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(defsystem :hu.dwim.reader+swank
  :defsystem-depends-on (:hu.dwim.asdf)
  :class "hu.dwim.asdf:hu.dwim.system"
  :description "Loads code that can deal with SBCL's #! syntax. Requires Swank to reuse its implementation."
  :depends-on (:hu.dwim.reader
               :swank)
  :components ((:module "integration"
                :components ((:file "sbcl+swank" :if-feature :sbcl)))))
