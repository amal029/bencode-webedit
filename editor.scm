;;; Author: Avinash Malik
;;; Date: Thu Apr  9 15:26:24 NZST 2015

;;; A Bencode-editor webapp

;;; Requirements: HTML5 supported webbrowser!

(use awful libencode s json)
(require-extension section-combinators)

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

(define (filter-pieces ll)
  (cond
   ((vector? ll)
    (apply vector (map filter-pieces (vector->list ll))))
   ((and (pair? ll) (equal? "pieces" (car ll)))
    (cons (car ll) "U"))
   ((list? ll)
    (map filter-pieces ll))
   ((pair? ll)
    (cons (car ll) (filter-pieces (cdr ll))))
   (else ll)))

;;; The function that gives back
;;; the components to display on the torrent-editor-page.
(define (tget ll name)
  (cond
   ((vector? ll)
    (find (lambda (x) (not (equal? x #f)))
	       (map (right-section tget name)
		    (vector->list ll))))
   ((and (pair? ll) (equal? name (car ll))) (cdr ll))
   ((list? ll) (find (lambda (x) (not (equal? x #f)))
			  (map (right-section tget name) ll)))
   ((pair? ll) (tget (cdr ll) name))
   (else #f)))

;;; This function returns the html code for torrent file
(define (output-html)
  (if ($ 'torrentfile as-boolean) (torrent-file
				   ($ 'fname as-string)
				   ($ 'fcontent as-string))
      (non-torrent-file ($ 'fname as-string))))

;;; The torrent-file html
;;; TODO: fill in text values on server side
(define torrent-file
  (lambda (fname content)
    (let* ((iport (open-input-string (hex->ascii content)))
	   (z (lib:decode iport))
	   (z (filter-pieces z))
	   (get-annouce-list (lambda ()
			       (let* ((x (tget z "announce-list"))
				      (x (if (not x) ""
					     (flatten x))))
				 "")))
	   (get-created-on (lambda ()
			     (let ((x (tget z "creation date")))
			       (if (not x) "" x))))
	   (get-created-by (lambda ()
			     (let ((x (tget z "created by")))
			       (if (not x) "" x))))
	   (get-comment (lambda () ""))
	   (get-piece-length (lambda ()
			       (let ((x (tget z "piece length")))
				 (if (not x) "" x))))
	   (get-file-name (lambda ()
			    (let ((x (tget z "name")))
			      (if (not x) "" x))))
	   (get-file-size (lambda ()
			    (let ((x (tget z "length")))
			      (if (not x) "" x)))))
      (close-input-port iport)
      `((form (h3 "Torrent")
	      (hr)
	      (div (b "File Name: "))
	      (div (input (@ (id "torrent-file-name")
			     (type "text")
			     (value ,fname))))
	      (br) (br) (br)
	      (h3 "Tracker")
	      (hr)
	      (div (b "URL: "))
	      (div (input (@ (id "torrent-file-url")
			 (type "text")
			 (value ,(get-annouce-list)))))
	      (br) (br) (br)
	      (h3 "Metadata")
	      (hr)
	      (div (b "Created on:"))
	      (div (input (@ (id "torrent-created-on")
			 (type "text")
			 (value ,(get-created-on)))))
	      (br)
	      (div (b "Created by:"))
	      (div (input (@ (id "torrent-created-by")
			 (type "text")
			 (value ,(get-created-by)))))
	      (br)
	      (div (b "Comment:"))
	      (div (input (@ (id "torrent-comment")
			 (type "text")
			 (value ,(get-comment)))))
	      (br)
	      (div (b "Piece length:"))
	      (div (input (@ (id "torrent-p-length")
			 (type "text")
			 (value ,(get-piece-length)))))
	      ;; The files
	      (br) (br) (br)
	      (h3 "Files")
	      (hr)
	      (div (b "Filename: "))
	      (div (input (@ (id "torrent-p-length")
			 (type "text")
			 (value ,(get-file-name)))))
	      (br)
	      (div (b "Filesize: "))
	      (div (input (@ (id "torrent-p-length")
			 (type "text")
			 (value ,(get-file-size)))))
	      )))))

;;; The non-torrent file html
(define non-torrent-file
  (lambda (fname content)
    '()))

;;; This function returns the bencoded file in json format
(define input-handle 
  (lambda ()
    (let* ((x ($ 'fcontent as-string))
	   (tfile ($ 'torrentfile as-boolean))
	   (iport (open-input-string (hex->ascii x)))
	   (oport (open-output-string))
	   (z (lib:decode iport))
	   (z (if tfile (filter-pieces z) z))
	   (_ (json-write z oport))
	   (y (get-output-string oport)))
      (close-input-port iport)
      (close-output-port oport)
      y)))


(define-page
  (main-page-path)
  (lambda ()
    (set-page-title! "Bencode Editor")
    (ajax "hdata" 'meme '() input-handle
	  use-sxml: #f)
    (ajax "myhtml" 'file '() output-html
	  use-sxml: #t)
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
      (div (@ (id "meme")))
      (div (@ (id "file")))))
  use-ajax: #t
  css: "editor.css"
  no-session: #t
  headers: (include-javascript "/html5file.js" "/readinput.js"))
