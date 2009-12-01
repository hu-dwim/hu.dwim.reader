;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(load-system :hu.dwim.asdf)

(in-package :hu.dwim.asdf)

(defsystem :hu.dwim.reader+hu.dwim.walker
  :class hu.dwim.system
  :depends-on (:hu.dwim.def+contextl
               :hu.dwim.reader
               :hu.dwim.walker)
  :components ((:module "integration"
                :components ((:file "walker")))))
