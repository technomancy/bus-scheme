$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class BusScheme::Lambda
  attr_accessor :body, :arg_names, :environment
end

class BusSchemeLambdaTest < Test::Unit::TestCase
  def test_simple_lambda
    l = eval("(lambda () (+ 1 1))")
    assert l.is_a?(BusScheme::Lambda)
    assert_equal [[:+, 1, 1]], l.body
    assert_equal [], l.arg_names

    eval("(define foo (lambda () (+ 1 1)))")
    assert BusScheme[:foo].is_a?(BusScheme::Lambda)
    assert_evals_to 2, [:foo]
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
    assert_raises(BusScheme::ArgumentError) { assert_evals_to 2, [:foo, 1, 3] }
  end

  def test_lambda_args_dont_stay_in_scope
    clear_symbols(:x, :foo)
    eval("(define foo (lambda (x) (+ x 1)))")
    assert_nil BusScheme.scope_of(:x)
    assert_evals_to 2, [:foo, 1]
    assert_nil BusScheme.scope_of(:x)
  end

  def test_lambda_calls_lambda
    eval "(define f (lambda (x) (+ 3 x)))"
    eval "(define g (lambda (y) (* 3 y)))"
    assert_evals_to 12, "(f (g 3))"
  end

  def test_lambda_closures
    eval "(define foo (lambda (x) ((lambda (y) (+ x y)) (* x 2))))"
    assert_evals_to 3, [:foo, 1]
  end

  def test_changes_to_enclosed_variables_are_in_effect_after_lambda_execution
    assert_evals_to 2, "((lambda (x) (begin ((lambda () (set! x 2))) x)) 1)"
  end

  def test_implicit_begin
    assert_evals_to 3, "((lambda () (intern \"hi\") (+ 2 2) (* 1 3)))"
  end
end
