(load "../../../examples/blog.scm")

(post 1 "hello world"
      "This is my bus scheme blog"
      (now))

(post 2 "hello again"
      (quote (p "this is my" (b "second") "post"))
      (now))

(assert-equal ((http-get "http://localhost:2000/1") 'body)
	      "This is my bus scheme blog")