(use awful)

(enable-sxml #t)

(define-page
  (main-page-path)
  (lambda ()
    (set-page-title! "Bencode Editor")
    (ajax "mo" 'mo 'click
	  (lambda ()
	    `(input (@ (type "file"))))
	  target: "file-input")
    `((ul (@ (class "menu"))
	  (li (a (@ (href "#")) "File")
	      (ul (li (a (@ (id "mo") (href "#")) "Open"))
		  (li (a (@ (id "mor") (href "#")) "Open Recent"))))
	  (li (a (@ (href "#")) "Edit")))
      (div (@ (id "file-input")))))
  use-ajax: #t
  css: "editor.css"
  no-session: #t)
