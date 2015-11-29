;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package "COM.INFORMATIMAGO.COMMON-LISP.SOURCE-TEXT")

(defun enable-shebang-syntax (&optional (readtable source-text:*source-readtable*))
  (reader:set-dispatch-macro-character #\# #\!
                                       (lambda (s c n)
                                         (declare (ignore n))
                                         (swank/sbcl::shebang-reader s c nil))
                                       readtable))
