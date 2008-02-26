(define isa? (lambda (x type)
	       (send x 'is_a? (ruby type))))

(define boolean? (lambda (x) (or (= x #t)
				 (= x #f))))
(define symbol? (lambda (x) (isa? x "Sym")))
(define cons? (lambda (x) (isa? x "Cons")))
(define pair? cons?)

(define string? (lambda (x) (isa? x "String")))
(define number? (lambda (x) (isa? x "Fixnum")))
(define vector? (lambda (x) (isa? x "Array")))
(define procedure? (lambda (x) (isa? x "Lambda")))
(define char? (lambda (x) (and (isa? x "String")
			       (= 1 (length x)))))

;;; TODO:
;;; port?
