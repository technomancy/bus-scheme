$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestLambda < Test::Unit::TestCase
  def test_simple_lambda
    l = eval_either("(lambda () (+ 1 1))")
    assert l.is_a?(Lambda)
    assert_equal [[:+.sym, 1, 1].to_list], l.body
    assert l.formals.empty?

    eval_either("(define foo (lambda () (+ 1 1)))")
    assert BusScheme[:foo.sym].is_a?(Lambda)
    assert_evals_to 2, cons(:foo.sym)
  end

  def test_lambda_with_arg
    eval_either("(define foo (lambda (x) (+ x 1)))")
    assert_evals_to 2, "(foo 1)"
  end

  def test_eval_literal_lambda
    assert_evals_to 4, "((lambda (x) (* x x)) 2)"
  end

  def test_lambda_with_incorrect_arity
    eval_either("(define foo (lambda (x) (+ x 1)))")
    assert_raises(ArgumentError) { assert_evals_to 2, "(foo 1 3)" }
  end

  def test_lambda_args_dont_stay_in_scope
    clear_symbols(:x, :foo)
    eval_either("(define foo (lambda (x) (+ x 1)))")
    assert ! BusScheme.in_scope?(:x)
    assert_evals_to 2, "(foo 1)"
    assert ! BusScheme.in_scope?(:x)
  end

  def test_lambda_calls_lambda
    eval_either "(define f (lambda (x) (+ 3 x)))"
    eval_either "(define g (lambda (y) (* 3 y)))"
    assert_evals_to 12, "(f (g 3))"
    assert_evals_to 1, "((lambda () ((lambda () 1))))"
  end

  def test_enforces_arg_count
    assert_equal 3, eval_either("(lambda (x y z) z)").formals.size
    assert_raises(ArgumentError) do
      eval_either "((lambda (x) x))"
    end
  end

  def test_lambda_closures
    assert_evals_to 3, "((lambda (x) ((lambda (y) 3) 1)) 1)"
    eval_either "(define foo (lambda (xx) ((lambda (y) (+ xx y)) (* xx 2))))"
    assert foo = BusScheme[:foo.sym]

    assert_evals_to 3, foo.call(cons(1))
    eval_either "(define holder ((lambda (x) (lambda () x)) 2))"
    assert_evals_to 2, "(holder)"
  end

  def test_changes_to_enclosed_variables_alter_original_bindings
    BusScheme.reset_stack # TODO: shouldn't reqire this
    assert_evals_to 2, "((lambda (x) ((lambda () (set! x 2))) x) 1)"
    assert BusScheme.stack.empty?
  end

  def test_implicit_begin
    assert_evals_to 3, "((lambda () (string->symbol \"hi\") (+ 2 2) (* 1 3)))"
  end

  def test_nested_function_calls_dont_affect_caller
    eval_either "(define fib (lambda (x)
              (if (< x 3)
                  1
                 (+ (fib (- x 1)) (fib (- x 2))))))"

    assert BusScheme.in_scope?(:fib.sym)
    assert_equal 1, BusScheme[:fib.sym].call(cons(2))
    assert_equal 5, BusScheme[:fib.sym].call(cons(5))
    assert_evals_to 5, "(fib 5)"
  end

  def test_lambda_rest_args
    eval_either "(define rest (lambda args args))"
    assert_evals_to [:a.sym, :b.sym, :c.sym].to_list, "(rest 'a 'b 'c)"
  end

  def test_stacktrace
    eval_either '(load "test/tracer.scm")'
    assert_equal ["(eval):1 in top-level"], eval_either("(stacktrace)")

    assert_equal(["test/tracer.scm:1 in f",
                  "test/tracer.scm:4 in g",
                  "(eval):1 in (anonymous)",
                  "(eval):0 in top-level"
                 ],
                 eval_either("((lambda () (g)))"))
  end

  # TODO: check the stack traces that the scheme tests give

  def test_stack_grows
    eval_either "(define stack-growth
(lambda () (ruby \"raise 'wtf' if BusScheme.stack.size < 1\")))"
    eval_either "(stack-growth)"
  end

  def test_primitives_live_on_stack
    BusScheme.define 'stack-growth', BusScheme.primitive { assert BusScheme.stack.size > 1 }
    assert SYMBOL_TABLE.has_key?('stack-growth'.sym)
    eval_either "(stack-growth)"
  end

  def test_array_to_hash
    a = [[1, 2], [3, 4], [5, 6]]
    assert_equal [1, 2, 3, 4, 5, 6], a.flatten_non_recursive
    assert_equal({ 1 => 2, 3 => 4, 5 => 6 }, a.to_hash)
  end

  def test_lambdas_accept_list_of_args
    BusScheme['foo'] = eval_either("(lambda (a) (assert-equal a 1))")
    BusScheme['foo'].call(cons(1))
  end
end
