;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package :hu.dwim.util)

(def package :hu.dwim.reader.test
  (:use :hu.dwim.common
        :hu.dwim.def
        :hu.dwim.stefil
        :hu.dwim.util)
  (:readtable-setup (enable-standard-hu.dwim-syntaxes)))
