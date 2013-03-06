;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(defsystem :hu.dwim.reader+hu.dwim.walker
  :defsystem-depends-on (:hu.dwim.asdf)
  :class "hu.dwim.asdf:hu.dwim.system"
  :depends-on (:hu.dwim.def+contextl
               :hu.dwim.reader
               :hu.dwim.walker)
  :components ((:module "integration"
                :components ((:file "walker")))))
