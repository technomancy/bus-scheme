(define post (lambda (id title body timestamp)
	       (resource (+ "/" (number->string id))
			 ;; Gah; i need quasiquote!
			 (list 'html (list 'head (list 'title title))
			       (list 'body
				     (list 'div
					   (list 'h1 title)
					   body))))))

(collection "/" (resources "/\d+"))

(load "posts/1.sexp")
(load "posts/2.sexp")