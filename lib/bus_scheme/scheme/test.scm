(define assert
  (lambda (bool)
    (if bool
        #t
        (fail "Assertion failed."))))

(define assert-equal
  (lambda (expected actual)
    (if (= expected actual)
        #t
        (fail (concat "Expected " (send expected 'inspect) ", got "
                      (send actual 'inspect))))))