#!/usr/bin/sbcl --script

;;* Quicklisp
(load "~/quicklisp/setup.lisp")
(ql:quickload "xmls" :silent t)
(ql:quickload "cl-ppcre" :silent t)

;;* Patch xmls by adding `nreverse' to attrs
;; Currently xmls-1.7 is offered by quicklisp
(in-package :xmls)
(defrule start-tag ()
  (let (name suffix attrs nsdecls)
    (and
     (peek namechar)
     (setf (values name suffix) (qname s))
     (multiple-value-bind (res a)
         (none-or-more s #'ws-attr-or-nsdecl)
       (mapcar (lambda (x) (if (eq (car x) 'attr)
                               (push (cdr x) attrs)
                             (push (cdr x) nsdecls)))
               a)
       res)
     (or (ws s) t)
     (values
      (make-node
       :name (or suffix name)
       :ns (and suffix name)
       :attrs (nreverse attrs))
      nsdecls))))

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

(defun print-usage ()
  (format t "Usage: ./xlx.lisp IN OUT~%"))

;;* Script
(let ((argv sb-ext:*posix-argv*))
  (if (= (length argv) 3)
      (let ((in (nth 1 argv))
            (out (nth 2 argv)))
        (cond ((cl-ppcre:scan "\\.xml$" in)
               (spit (parse (slurp in)) out))
              ((cl-ppcre:scan "\\.lisp$" in)
               (spit-as-xml (read-from-string (slurp in)) out))
              (t
               (print-usage))))
    (print-usage)))
