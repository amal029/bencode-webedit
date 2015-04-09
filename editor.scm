(use awful)
(import libencode)

(enable-sxml #t)
(literal-script/style? #t)

(page-css "editor.css")

;;; The path name of the file
(define file-name "")

(define-page
  (main-page-path)
  (lambda ()
    (set-page-title! "Bencode Editor")
    (ajax "mo" 'myInput 'change
    	  (lambda ()
	    (set! file-name ($ 'myInput as-string))
	    '())
	  arguments:'((myInput . "$('#myInput').val()"))
	  success: "$('#target').submit();")
    (ajax "submit-handler" 'target 'submit
	  (lambda ()
	    `(b ,file-name)))
    `((ul (@ (class "menu"))
	  (li (a (@ (href "#")) "File")
	      (ul 
	       (div
		(@ (id "ofile")
		   (onclick 
		    "document.getElementById('myInput').click();"))
		(form (@ (id "target")
			 (action "/ajax/submit-handler")
			 (enctype "multipart/form-data")
			 (method "post"))
		 (input (@ (type "file")
			   (id "myInput")
			   (value "Go")
			   (style "display:none"))))
		(li (a (@ (id "mo") (href "#")) 
		       "Open")))
	       (li (a (@ (id "mor") (href "#")) "Open Recent"))))
	  (li (a (@ (href "#")) "Edit")))
      (div (@ (id "file-input")))))
  use-ajax: #t
  css: "editor.css"
  no-session: #t)
