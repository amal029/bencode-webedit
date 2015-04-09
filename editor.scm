;;; Author: Avinash Malik
;;; Date: Thu Apr  9 15:26:24 NZST 2015

;;; A Bencode-editor webapp

;;; Requirements: HTML5 supported webbrowser!

(import (prefix libencode lib:))
(use awful)

(enable-sxml #t)
(literal-script/style? #t)

(page-css "editor.css")

(define-page
  (main-page-path)
  (lambda ()
    (set-page-title! "Bencode Editor")
    (ajax "hdata" 'meme '()
	  (lambda ()
	    (let* ((x ($ 'fcontent as-string))
		   ;; (iport (open-input-string x))
		   ;; (y `(b ,(lib:decoder iport)))
		   ;; (close-input-port iport)
		   )
	      (display x)
	      (newline)
	      ;; (display y)
	      ;; (newline)
	      x))
	  target: "sformat")
    `((ul (@ (class "menu"))
	  (li (a (@ (href "#")) "File")
	      (ul 
	       (div
		(@ (id "ofile")
		   (onclick 
		    "document.getElementById('myInput').click();"))
		(input (@ (type "file")
			  (id "myInput")
			  (style "display:none")))
		(li (a (@ (id "mo") (href "#")) 
		       "Open")))
	       (li (a (@ (id "mor") (href "#")) "Open Recent"))))
	  (li (a (@ (href "#")) "Edit")))
      (div (@ (id "meme"))
	   (textarea (@ (id "sformat"))))))
  use-ajax: #t
  css: "editor.css"
  no-session: #t
  headers: (include-javascript "/html5file.js" "/readinput.js"))
