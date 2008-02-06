(define intern
  (lambda (sym) (send sym (quote intern))))

(define substring
  (lambda (string to from) (send string (quote []) to from)))

(define null?
  (lambda (expr) (= expr ())))

(define >
  (lambda (x y) (send x (intern ">") y)))

(define <
  (lambda (x y) (send x (intern "<") y)))

(define =
  (lambda (x y) (send x (intern "==") y)))

(define not
  (lambda (expr) (if expr #f #t)))

(define car
  (lambda (lst) (send lst (quote first))))

(define cdr
  (lambda (lst) (send lst (quote rest))))

(define cadr
  (lambda (lst) (car (cdr lst))))