;;; Author: Avinash Malik
;;; Date: Thu Apr  9 15:26:24 NZST 2015

;;; A Bencode-editor webapp

;;; Requirements: HTML5 supported webbrowser!

(use awful libencode s json srfi-19)
(require-extension section-combinators)

(enable-sxml #t)
(literal-script/style? #t)

(page-css "editor.css")

(define (foldi func init lst)
  (letrec ((ffold (lambda (counter func init lst)
		    (cond
		     ((null? lst) init)
		     (else (ffold (+ 1 counter)
				  func
				  (func counter init (car lst))
				  (cdr lst)))))))
    (ffold 0 func init lst)))

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

;;; This function updates the torrent file with the new information.
;;; FIXME: Add new pairs if they don't already exist!
(define (tupdate tcby tcon tcom turls ll)
  (cond
   ((vector? ll) (list->vector
		  (map (left-section tupdate tcby tcon tcom turls)
		       (vector->list ll))))
   ((list? ll) (map (left-section tupdate tcby tcon tcom turls) ll))
   ((pair? ll)
    (cond
     ((equal? "announce-list" (car ll))
      (cons (car ll) (if (not turls) (cdr ll) turls)))
     ((equal? "created by" (car ll))
      (cons (car ll) (if (not tcby) (cdr ll) tcby)))
     ((equal? "creation date" (car ll))
      (cons (car ll) (if (not tcon) (cdr ll) tcon)))
     (else (cons (car ll) (tupdate tcby tcon tcom turls (cdr ll))))))
   (else ll)))

;;; This function returns a string, which is pretty much the updated
;;; torrent file.
(define (update-torrent)
  (let* ((file-name ($ 'fname as-string))
	 (content ($ 'fcontent as-string))
	 (tcby ($ 'tcby as-string))
	 (tcon (time->seconds
		(date->time (string->date ($ 'tcon as-string)))))
	 (tcom ($ 'tcom as-string))
	 (turls ($ 'turls as-list))
	 (iport (open-input-string (hex->ascii content)))
	 (z (lib:decode iport))
	 (_ (close-input-port iport))
	 (y (tupdate tcby tcon tcom turls z))
	 (res (lib:encode y))
	 (oport (open-output-file (++ "./downloads/" file-name))))
    (write-string res #f oport)
    (close-output-port oport)
    `((h1 ,(++ "Please click the download link below "
	      "to save the updated torrent file to disk"))
      (br)
      (a (@ (href ,(++ "/downloads/" file-name))) ,file-name))))

;;; This function returns the html code for torrent file
(define (output-html)
  (if ($ 'torrentfile as-boolean) (torrent-file
				   ($ 'fname as-string)
				   ($ 'fcontent as-string))
      (non-torrent-file ($ 'fname as-string)
			($ 'fcontent as-string))))

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
				 x)))
	   (get-created-on (lambda ()
			     (let ((x (tget z "creation date")))
			       (if (not x) ""
				   (date->string
				    (seconds->date x))))))
	   (get-created-by (lambda ()
			     (let ((x (tget z "created by")))
			       (if (not x) "" x))))
	   (get-comment (lambda () ""))
	   (get-piece-length (lambda ()
			       (let ((x (tget z "piece length")))
				 (if (not x) "" (/ x 1024)))))
	   (get-file-name (lambda ()
			    (let ((x (tget z "name")))
			      (if (not x) "" x))))
	   (get-file-size (lambda ()
			    (let ((x (tget z "length")))
			      (if (not x) "" x)))))
      (close-input-port iport)
      `(form (@ (id "torrentForm")
		(action "/ajax/updateTorrent")
		(onsubmit "torrentSubmit(event)"))
	     (h3 "Torrent")
	     (hr)
	     (div (b "File Name: "))
	     (div (input (@ (id "torrent-file-name")
			    (type "text")
			    (value ,fname))))
	     (br) (br) (br)
	     (h3 "Tracker")
	     (hr)
	     (div (b "URL: "))
	     ,(let* ((x (get-annouce-list))
		     (msize (apply max (map string-length x))))
		(foldi (lambda (i l x)
			 (cons
			  `(div (input
				 (@
				  (type "text")
				  (value ,x)
				  (size ,msize)
				  (id
				   ,(++ "url" (number->string i)))))
				(br) (br)) l))
			'() x))
	     
	     (br) (br) (br)
	     (h3 "Metadata")
	     (hr)
	     (div (b "Created on:"))
	     (div (input (@ (id "torrent-created-on")
			    (type "text")
			    (value ,(get-created-on))
			    (size ,(string-length
				    (get-created-on))))))
	     (br)
	     (div (b "Created by:"))
	     (div (input (@ (id "torrent-created-by")
			    (type "text")
			    (value ,(get-created-by))
			    (size ,(string-length
				    (get-created-by))))))
	     (br)
	     (div (b "Comment:"))
	     (div (input (@ (id "torrent-comment")
			    (type "text")
			    (value ,(get-comment)))))
	     (br)
	     (div (b "Piece length (KB):"))
	     (div (input (@ (id "torrent-p-length")
			    (type "text")
			    (value ,(get-piece-length))
			    (disabled "disabled"))))
	     ;; The files
	     (br) (br) (br)
	     (h3 "Files")
	     (hr)
	     (div (b "Filename: "))
	     (div (input (@ (id "torrent-f-name")
			    (type "text")
			    (value ,(get-file-name))
			    (size ,(string-length
				    (get-file-name)))
			    (disabled "disabled"))))
	     (br)
	     (div (b "Filesize (MB): "))
	     (div (input (@ (id "torrent-f-size")
			    (type "text")
			    (disabled "disabled")
			    (value
			     ,(/ (get-file-size) 1048576)))))
	     (br) (br)
	     (div
	      (input (@
		      (id "update-button")
		      (type "submit")
		      (value "Update!"))))))))

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
    (ajax "updateTorrent" 'file '() update-torrent
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
