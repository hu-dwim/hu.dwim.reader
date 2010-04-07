;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package :hu.dwim.def)

(def package :hu.dwim.reader.test
  (:use :hu.dwim.common
        :hu.dwim.def
        :hu.dwim.stefil
        :hu.dwim.util)
  (:readtable-setup (hu.dwim.util:enable-standard-hu.dwim-syntaxes)))
