(define string->symbol
  (lambda (sym) (send sym 'sym)))

(define number->string
  (lambda (number) (send number 'to_s)))

(define substring
  (lambda (string to from) (send string (quote []) to from)))

(define null?
  (lambda (expr) (or
	     ;; TODO: empty list isn't nil... not really
	     (= expr ()) ;; hacky?
	     (= expr (ruby "nil")))))

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

;; cond
(define else #t)