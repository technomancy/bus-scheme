(assert #t)

;; Arithmetic
(assert-equal 2 (+ 1 1))
(assert-equal 2 (/ 4 2))
(assert-equal 2 (* 1 2))

(assert-equal 4 (+ 1 1 1 1))
(assert-equal 2 (* 1 2 1 1))

(assert-equal "foobar" (concat "foo" "bar"))
(assert-equal "foofoofoo" (ruby "'foo' * 3"))
(assert-equal 7 (send 3 (string->symbol "+") 4))

(assert-equal 9 (begin (define foo 779) 9))
(assert-equal 779 foo)

(assert (null? (cdr (cons 3 ()))))

;; define
(define foo 5)
(define bar (quote (5 5 5)))
(assert-equal 5 foo)
(assert-equal (list 5 5 5) bar)

(assert-equal 'foo (define foo 5))

;;  special forms
(assert-equal 7 (if #f 3 7))
(assert-equal 3 (if (> 8 2) 3 7))

;; TODO: get let working here
;; (assert-equal 4 (let ((x 2)
;; 		      (y 2))
;; 		  (+ x y)))
;; (assert-equal 6 (let ((doubler (lambda (x) (* 2 x)))
;; 		      (x 3))
;; 		  (doubler x)))

(assert-equal #t (and #t #t))
(assert-equal #f (and #t #f))
(assert-equal #f (and #f #t))
(assert-equal #f (and #f #f))

(assert-equal #t (or #t #t))
(assert-equal #t (or #t #f))
(assert-equal #t (or #f #t))
(assert-equal #f (or #f #f))

;; TODO: parse error if this isn't the last thing in the file.
(assert-equal 23 (eval '(+ 20 3)))
