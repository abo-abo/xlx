#!/usr/bin/sbcl --script
(load "~/quicklisp/setup.lisp")
(ql:quickload "xmls")
(write-line "Hello, World!")
(print sb-ext:*posix-argv*)
