#!/usr/bin/sbcl --script

;;* Quicklisp
(load "~/quicklisp/setup.lisp")
(ql:quickload "xmls")

;;* Package
(defpackage myscript
  (:use :common-lisp :xmls))

(in-package :myscript)

;;* Functions
(defun slurp (file-name)
  (with-open-file (stream file-name)
    (let ((contents (make-string (file-length stream))))
      (read-sequence contents stream)
      contents)))

(defun spit (x file-name)
  (with-open-file (str file-name
                       :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
    (format str "~S~%" x)))

(defun spit-as-xml (x file-name)
  (with-open-file (str file-name
                       :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
    (write-prologue '(("version" . "1.0")
                      ("encoding" . "UTF-8")) nil str)
    (write-xml x str :indent t)))

;;* Script
;; (write-line "Hello, World!")
;; (print sb-ext:*posix-argv*)
(defparameter xml-name "/home/oleh/Software/xmls-1.7.1/tests/rss.xml")
(setq xml-name "/home/oleh/Software/jenkins-wrapper/jenkins/jobs/demo_pipeline/config.xml")
(let ((xml-lisp (parse (slurp xml-name))))
  (spit xml-lisp "/home/oleh/demo_pipeline.lisp")
  (spit-as-xml xml-lisp "/home/oleh/demo_pipeline.xml"))
