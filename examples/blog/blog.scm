(define post (lambda (id title body timestamp)
	       (resource (+ "/" (number->string id))
			 ;; Gah; i need quasiquote!
			 (list 'html (list 'head (list 'title title))
			       (list 'body
				     (list 'div
					   (list 'h1 title)
					   body))))))

(collection "/" (list 
		 (post 1 "hello world"
		       "This is my bus scheme blog"
		       (now))

		 (post 2 "hello bus scheme"
		       "This is the awesome blog"
		       (now))))