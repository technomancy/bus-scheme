(assert #t)

;; Arithmetic
(assert-equal 2 (+ 1 1))
(assert-equal 2 (/ 4 2))
(assert-equal 2 (* 1 2))

(assert-equal 4 (+ 1 1 1 1))
(assert-equal 2 (* 1 2 1 1))

(assert-equal "foobar" (concat "foo" "bar"))
(assert-equal 23 (eval '(+ 20 3)))
;; (assert-equal "foofoofoo" (ruby "'foo' * 3"))
;; (assert-equal 7 (send 3 (string->symbol "+") 4))

;; (load "../examples/fib.scm")
(define fib (lambda (x)
	      (if (< x 3)
		  1
		  (+ (fib (- x 1))
		     (fib (- x 2))))))
(assert fib)
(assert-equal (list 1 1 2 3 5 8)
	      (map fib (list 1 2 3 4 5)))