(load "../../../examples/fib.scm")
(assert fib)

(assert-equal (list 1 1 2 3 5 8)
              (map fib (list 1 2 3 4 5 6)))