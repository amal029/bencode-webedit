;;; Author: Avinash Malik
;;; Date: Thu Apr  9 15:26:24 NZST 2015

;;; A Bencode-editor webapp

;;; Requirements: HTML5 supported webbrowser!

(use awful libencode s json)

(enable-sxml #t)
(literal-script/style? #t)

(page-css "editor.css")

(define (hex->ascii hstr)
  (let ((hstrl (string->list hstr)))
    (let-values (((f s) (partition-indexed
			 (lambda (_ i)
			   (equal? (modulo i 2) 0)) hstrl)))
      (if (= (length f) (length s))
	  (let ((ff (foldl
		     (lambda (l pr)
		       (let ((p
			      (integer->char
			       (string->number
				(s-prepend "#x"(list->string pr))))))
			 (cons p l)))
			   '() (zip f s))))
	    (list->string ff))
	  (error "Malformed URI"
		 (cons (length hstrl)
		       (cons (length f) (length s))))))))

(define input-handle 
  (lambda ()
    (let* ((x ($ 'fcontent as-string))
	   (iport (open-input-string (hex->ascii x)))
	   (oport (open-output-string))
	   (_ (json-write (lib:decode iport) oport))
	   (y (get-output-string oport)))
      (close-input-port iport)
      (close-output-port oport)
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
