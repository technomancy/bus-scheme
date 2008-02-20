;; Test list functions defined in list.scm

(assert-equal (quote (1 2 3)) (reverse (quote (3 2 1))))

(assert-equal (quote (1 2 3 4)) (append (quote ()) (quote (1 2 3 4))))
(assert-equal (quote (1 2 3 4)) (append (quote (1 )) (quote (2 3 4))))
(assert-equal (quote (1 2 3 4)) (append (quote (1 2 )) (quote (3 4))))
(assert-equal (quote (1 2 3 4)) (append (quote (1 2 3 )) (quote (4))))
(assert-equal (quote (1 2 3 4)) (append (quote (1 2 3 4)) (quote ())))
