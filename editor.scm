;;; Author: Avinash Malik
;;; Date: Thu Apr  9 15:26:24 NZST 2015

;;; A Bencode-editor webapp

;;; Requirements: HTML5 supported webbrowser!

(use awful libencode)

(enable-sxml #t)
(literal-script/style? #t)

(page-css "editor.css")

(define input-handle 
  (lambda ()
    (let* ((x ($ 'fcontent as-string))
	   (iport (open-input-string x))
	   (y (lib:decode iport))
	   (_ (close-input-port iport)))
      y)))
      

(define-page
  (main-page-path)
  (lambda ()
    (set-page-title! "Bencode Editor")
    (ajax "hdata" 'meme '() input-handle)
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
