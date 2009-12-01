;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(load-system :hu.dwim.asdf)

(in-package :hu.dwim.asdf)

(defsystem :hu.dwim.reader+hu.dwim.syntax-sugar
  :class hu.dwim.system
  :depends-on (:hu.dwim.reader
               :hu.dwim.syntax-sugar)
  :components ((:module "integration"
                :components ((:file "syntax-sugar")))))
