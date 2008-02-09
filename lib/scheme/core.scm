(define intern
  (lambda (sym) (send sym 'intern)))

(define substring
  (lambda (string to from) (send string (quote []) to from)))

(define null?
  (lambda (expr) (= expr ())))

(define >
  (lambda (x y) (send x '> y)))

(define <
  (lambda (x y) (send x '< y)))

(define =
  (lambda (x y) (send x '== y)))

(define not
  (lambda (expr) (if expr #f #t)))

(define car
  (lambda (lst) (send lst 'first)))

(define cdr
  (lambda (lst) (send lst 'rest)))

;; and friends
(define cadr
  (lambda (lst) (car (cdr lst))))