(use awful)
(import libencode)

(enable-sxml #t)
(literal-script/style? #t)

(define-page
  (main-page-path)
  (lambda ()
    (set-page-title! "Bencode Editor")
    (ajax "mo" 'ofile 'click
    	  (lambda ()
    	    (let ((fname ($ 'myInput)))
	      `(b ,fname)))
	  target: "file-input")
    `((ul (@ (class "menu"))
	  (li (a (@ (href "#")) "File")
	      (ul 
	       (div (@ (id "ofile")
		       (onclick 
			"document.getElementById('myInput').click();"))
		    (input (@ (type "file")
			      (id "myInput")
			      (style "display:none")))
		    (li (a (@ (id "mo") (href "#")) 
			   "Open")))
	       (li (a (@ (id "mor") (href "#")) "Open Recent"))))
	  (li (a (@ (href "#")) "Edit")))
      (div (@ (id "file-input")))))
  use-ajax: #t
  css: "editor.css"
  no-session: #t)
