(define length (lambda (l)
   (if (null? l) 0 (+ 1 (length (cdr l))))))

(define append
  (lambda (l1 l2)
    (if (null? l1) l2 (cons (car l1) (append (cdr l1) l2)))))

(define reverse
  (lambda (l)
    (if (null? l) '() (append (reverse (cdr l)) (list (car l))))))