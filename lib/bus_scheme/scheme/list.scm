(define select
  (lambda (fn lst)
    (if (not (null? lst))
	(if (fn (car lst))
	    (cons (car lst) (select fn (cdr lst)))
	    (select fn (cdr lst))))))

(define length (lambda (l)
   (if (empty? l) 0 (+ 1 (length (cdr l))))))

(define append
  (lambda (l1 l2)
    (if (null? l1) 
	l2 
	(cons (car l1) (append (cdr l1) l2)))))

(define reverse
  (lambda (l)
    (if (null? l) '() (append (reverse (cdr l)) (list (car l))))))