(define intern
  (lambda (sym) (send sym (quote intern))))

(define substring
  (lambda (string to from) (send string (quote []) to from)))

(define null?
  (lambda (sym) (send sym (intern "nil?"))))

(define >
  (lambda (x y) (send x (intern ">") y)))

(define <
  (lambda (x y) (send x (intern "<") y)))

(define =
  (lambda (x y) (send x (intern "==") y)))

(define not
  (lambda (expr) (if expr #f #t)))

";;;     :car => lambda { |list| list.car },
;;;     :cdr => lambda { |list| list.cdr },
"