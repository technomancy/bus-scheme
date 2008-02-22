(define f (lambda () (stacktrace)))

(define g (lambda ()
  (f)))