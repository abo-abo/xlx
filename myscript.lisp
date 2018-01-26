#!/usr/bin/sbcl --script

;;* Quicklisp
(load "~/quicklisp/setup.lisp")
(ql:quickload "xmls")

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

;;* Script
(print sb-ext:*posix-argv*)
(defparameter argv sb-ext:*posix-argv*)
(let* ((in-xml (nth 1 argv))
       (out (nth 2 argv))
       (out-lisp (concatenate 'string out ".lisp"))
       (out-xml (concatenate 'string out ".xml"))
       (xml-lisp (parse (slurp in-xml))))
  (spit xml-lisp out-lisp)
  (spit-as-xml xml-lisp out-xml))
