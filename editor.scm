;;; Author: Avinash Malik
;;; Date: Thu Apr  9 15:26:24 NZST 2015

;;; A Bencode-editor webapp

;;; Requirements: HTML5 supported webbrowser!

(use awful libencode)

(enable-sxml #t)
(literal-script/style? #t)

(page-css "editor.css")

(define (partition-indexed f l)
  (letrec ((part (lambda (fi se count ll)
		   (if (null? ll)
		       (values fi se)
		       (cond
			((f (car ll) count)
			 (part (cons (car ll) fi) se
			       (+ count 1)
			       (cdr ll)))
			(else
			 (part fi (cons (car ll) se)
			       (+ count 1)
			       (cdr ll))))))))
    (part '() '() 0 l)))

(define (hex->ascii hstr)
  (let ((hstrl (string->list hstr)))
    (let-values (((f s) (partition-indexed
			 (lambda (_ i)
			   (equal? (modulo i 2) 0)) hstrl)))
      (if (= (length f) (length s))
	  (let ((ff (foldl (lambda (l pr)
			     (let ((_ (display pr))
				   ;; (p (integer->char
				   ;;     (string->number
				   ;; 	(list->string pr))))
				   )
			       ;; (cons p l)
			       l
			       ))
			   '() (zip f s))))
	    (list->string ff))
	  (error "Malformed URI" (cons (length hstrl)
				       (cons (length f) (length s))))))))

(define input-handle 
  (lambda ()
    (let* ((x ($ 'fcontent as-string))
	   (iport (open-input-string (hex->ascii x)))
	   ;; (oport (open-output-file "/tmp/obj.txt"))
	   ;; (y (lib:decode iport))
	   )
      ;; (write-string x #f oport)
      (close-input-port iport)
      ;; (close-output-port oport)
      x)))
      

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
