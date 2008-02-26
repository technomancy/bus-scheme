;; still to test: number? vector? procedure? char? port?

(assert (boolean? (> 3 2)))
(assert (boolean? (> 1 2)))
(assert (not (boolean? 3)))
(assert (not (boolean? "hi")))
(assert (not (boolean? >)))

(assert (symbol? 'hi))
(assert (symbol? (quote hullo)))
(assert (not (symbol? "hi")))
(assert (not (symbol? 23)))
(assert (not (symbol? assert)))

(assert (cons? (cons 1 2)))
(assert (cons? cons?))
(assert (not (cons? 2)))
(assert (not (cons? #t)))
(assert (pair? (cons 1 2)))

(assert (string? "h"))
(assert (string? "hello"))
(assert (not (string? 'hi)))
(assert (not (string? string?)))