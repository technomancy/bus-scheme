
(define fib (lambda (x)
	      (if (< x 3)
		  1
		  (+ (fib (- x 1))
		     (fib (- x 2))))))