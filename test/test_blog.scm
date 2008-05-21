(load "../../../examples/blog/blog.scm")

(post 1 "hello world"
      "This is my bus scheme blog"
      (now))

(post 2 "hello again"
      (quote (p "this is my" (b "second") "post"))
      (now))

;; TODO: test this stuff!