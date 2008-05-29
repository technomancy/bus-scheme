(define blog-posts ())

(define post
  (lambda (id title body timestamp tags)
    (define blog-posts (cons 
			(defresource (+ "/"
					(number->string id))
			  ;; Gah; i need quasiquote!
			  (list 'html (list 'head
					    (list p'title
						  title))
				(list 'body
				      (list 'div 'class "post"
					    (list 'h1 title)
					    body))))
			blog-posts))))

(defresource "/" (lambda (env)
		   (map (lambda (post)
			  (list 'div 'class "post"
				(list 'h1 (post 'title))
				(post 'body)))
			(resources-list))))

