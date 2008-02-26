;;; char?
;;; vector?
;;; procedure?
;;; pair?
;;; number?
;;; string?
;;; port?

(define boolean? (lambda (x) (or (= x #t)
				 (= x #f))))

(define symbol? (lambda (x) (send x 'is_a? (ruby "Sym"))))