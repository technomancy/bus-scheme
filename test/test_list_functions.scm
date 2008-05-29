;; Test list functions defined in list.scm

(assert-equal (list 1 2) (append (list 1) (list 2)))

(assert-equal (quote (1 2 3 4)) (append (quote ()) (quote (1 2 3 4))))
(assert-equal (quote (1 2 3 4)) (append (quote (1 )) (quote (2 3 4))))
(assert-equal (quote (1 2 3 4)) (append (quote (1 2 )) (quote (3 4))))
(assert-equal (quote (1 2 3 4)) (append (quote (1 2 3 )) (quote (4))))

;; TODO: fix these!
;; (assert-equal (quote (1 2 3 4)) (append (quote (1 2 3 4)) (quote ())))
;; (assert-equal (list 1 2 3) (reverse (list 3 2 1)))

(assert-equal (length "abc") 3)
(assert-equal (length "ab") 2)
(assert-equal (length "a") 1)

(assert-equal (list 4 5 6)
 (select (lambda (n) (> n 3)) (list 1 2 3 4 5 6 1)))