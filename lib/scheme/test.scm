(define fail (lambda (message)
	       (ruby (concat "raise AssertionFailed"))))

(define assert 
  (lambda (bool)
    (if bool
	#t
	(fail "Assertion failed."))))

(define assert-equal 
  (lambda (expected actual)
    (if (= expected actual)
	#t
	(fail (concat "Expected " expected ", got " actual)))))