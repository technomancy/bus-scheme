(define post (lambda (id title body timestamp)
	       (defresource (+ "/" (number->string id))
			 ;; Gah; i need quasiquote!
			 (list 'html (list 'head (list 'title title))
			       (list 'body
				     (list 'div
					   (list 'h1 title)
					   body))))))
