;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(load-system :hu.dwim.asdf)

(in-package :hu.dwim.asdf)

(defsystem :hu.dwim.reader
  :class hu.dwim.system
  :author ("Attila Lendvai <attila.lendvai@gmail.com>"
           "Levente Mészáros <levente.meszaros@gmail.com>"
           "Tamás Borbély <tomi.borbely@gmail.com>")
  :licence "BSD / Public domain"
  :description "Template for hu.dwim.reader"
  :components ((:module "source"
                :components ((:file "reader" :depends-on ("source-form"))
                             (:file "source-form")
                             (:file "source-text" :depends-on ("reader"))))
               (:module "integration"
                :components ((:file "hu.dwim.reader+sbcl")))))
