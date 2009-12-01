;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(load-system :hu.dwim.asdf)

(in-package :hu.dwim.asdf)

(defsystem :hu.dwim.reader.documentation
  :class hu.dwim.documentation-system
  :depends-on (:hu.dwim.reader.test
               :hu.dwim.wui)
  :components ((:module "documentation"
                :components ((:file "reader" :depends-on ("package"))
                             (:file "package")))))
