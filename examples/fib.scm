;; Fibonacci sequence
(define fib (lambda (x)
;;	      (ruby "puts Lambda[:x.sym]")
	      (if (< x 3)
		  1
		  (+ (fib (- x 1))
		     (fib (- x 2))))))