$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class BusScheme::Lambda
  attr_accessor :body, :formals, :enclosing_scope

  def self.stack
    @@stack
  end
end

class BusSchemeLambdaTest < Test::Unit::TestCase
  def test_simple_lambda
    l = eval("(lambda () (+ 1 1))")
    assert l.is_a?(Lambda)
    assert_equal [[:+.sym, 1, 1]], l.body
    assert_equal [], l.formals

    eval("(define foo (lambda () (+ 1 1)))")
    assert Lambda[:foo.sym].is_a?(Lambda)
    assert_evals_to 2, [:foo.sym]
  end

  def test_lambda_with_arg
    eval("(define foo (lambda (x) (+ x 1)))")
    assert_evals_to 2, [:foo, 1]
  end

  def test_eval_literal_lambda
    assert_evals_to 4, "((lambda (x) (* x x)) 2)"
  end

  def test_lambda_with_incorrect_arity
    eval("(define foo (lambda (x) (+ x 1)))")
    assert_raises(ArgumentError) { assert_evals_to 2, [:foo, 1, 3] }
  end

  def test_lambda_args_dont_stay_in_scope
    clear_symbols(:x, :foo)
    eval("(define foo (lambda (x) (+ x 1)))")
    assert_nil Lambda[:x]
    assert_evals_to 2, [:foo, 1]
    assert_nil Lambda[:x]
  end

  def test_lambda_calls_lambda
    eval "(define f (lambda (x) (+ 3 x)))"
    eval "(define g (lambda (y) (* 3 y)))"
    assert_evals_to 12, "(f (g 3))"
  end

  def test_lambda_closures
    eval "(define foo (lambda (x) ((lambda (y) (+ x y)) (* x 2))))"
    assert_evals_to 3, [:foo, 1]
    eval "(define holder ((lambda (x) (lambda () x)) 2))"
    assert_evals_to 2, "(holder)"
  end

  def test_changes_to_enclosed_variables_are_in_effect_after_lambda_execution
    assert_evals_to 2, "((lambda (x) (begin ((lambda () (set! x 2))) x)) 1)"
  end

  def test_implicit_begin
    assert_evals_to 3, "((lambda () (string->symbol \"hi\") (+ 2 2) (* 1 3)))"
  end

  def test_shadowed_vars_dont_stay_in_scope
    assert_evals_to Cons.new(:a.sym, :b.sym), "(let ((f (let ((x (quote a)))
          (lambda (y) (cons x y)))))
 (let ((x (quote not-a)))
  (f (quote b))))"
  end

  def test_nested_function_calls_dont_affect_caller
    eval "(define fib (lambda (x)
	      (if (< x 3)
		  1
                 (+ (fib (- x 1)) (fib (- x 2))))))"

    assert_evals_to 5, "(fib 5)"
  end

  def test_lambda_rest_args
    eval "(define rest (lambda args args))"
    assert_evals_to [:a.sym, :b.sym, :c.sym].to_list, "(rest 'a 'b 'c)"
  end

  def test_stacktrace
    eval "
(define gimme-trace (lambda () (stacktrace)))

(define nest-trace (lambda ()
  (gimme-trace)))"

    assert_equal ["(eval)", 1, '(top-level)'], eval("(gimme-trace)")
    
    assert_equal([["(eval)", 2, :'gimme-trace'.sym],
                  ["(eval)", 5, :'nest-trace'.sym],
                  ['anonymous'],
                  ["(eval)", 1, '(top-level)']],
                 eval("((lambda () (nest-trace)))"))
#    eval "(trace)"
  end

  def test_stack_grows
    eval "(define stack-growth
(lambda () (ruby \"raise 'wtf' if Lambda.stack.size < 1\")))"
    eval "(stack-growth)"
  end

#   def test_stack_grows_with_primitives
#     BusScheme::define 'stack-growth', lambda { assert Lambda.stack.size > 1 }
#     eval "(stack-growth)"
#   end
end
