$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class BusSchemeEvalTest < Test::Unit::TestCase
  def test_eval_empty_list
    assert_evals_to nil, []
  end

  def test_eval_number
    assert_evals_to 2, 2
  end

  def test_eval_symbol
    BusScheme::SYMBOL_TABLE[:hi] = nil
    assert_evals_to nil, :hi
  end

  def test_eval_string
    assert_evals_to "hi", "\"hi\""
  end

  def test_eval_function_call
    assert_evals_to 2, [:+, 1, 1]
  end

  def test_many_args_for_arithmetic
    assert_evals_to 4, [:+, 1, 1, 1, 1]
    assert_evals_to 2, [:*, 1, 2, 1, 1]
  end

  def test_arithmetic
    assert_evals_to 2, [:'-', 4, 2]
    assert_evals_to 2, [:'/', 4, 2]
    assert_evals_to 2, [:'*', 1, 2]
  end

  def test_define
    assert_equal nil, BusScheme::SYMBOL_TABLE[:foo]
    BusScheme.eval_string("(define foo 5)")
    assert_equal 5, BusScheme::SYMBOL_TABLE[:foo]
    BusScheme.eval_string("(define foo (quote (5 5 5))")
    assert_evals_to [5, 5, 5], :foo
  end

  def test_define_returns_defined_term
    assert_evals_to :foo, "(define foo 2)"
    # can't use the eval convenience testing method since it assumes strings are unparsed
    assert_equal 2, BusScheme.eval_string("foo")
  end

  def test_string_primitives
    assert_evals_to :hi, [:intern, 'hi']
    assert_evals_to 'helloworld', [:concat, 'hello', 'world']
    assert_evals_to 'lo', [:substring, 'hello', 3, -1]
  end

  def test_eval_quote
    assert_evals_to [:'+', 2, 2], [:quote, [:'+', 2, 2]]
  end

  def test_quote
    assert_evals_to :hi, [:quote, :hi]
  end

  def test_nested_arithmetic
    assert_evals_to 6, [:+, 1, [:+, 1, [:*, 2, 2]]]
  end

  def test_blows_up_with_undefined_symbol
    assert_raises(RuntimeError) { BusScheme.eval_string("undefined-symbol") }
  end

  def test_variable_substitution
    BusScheme::SYMBOL_TABLE[:foo] = 7
    assert_evals_to 7, :foo
    assert_evals_to 21, [:*, 3, :foo]
  end

  def test_if
    assert_evals_to 7 [:if, false, 3, 7]
    assert_evals_to 3 [:if, [:>, 8, 2], 3, 7]
  end

  def test_begin
    BusScheme::eval([:begin,
                     [:define, :foo, 779],
                     9])
    assert_equal 779, BusScheme::SYMBOL_TABLE[:foo]
  end

  def test_set!
    # i dunno... what does set! do? how's it different from define?
  end

  def test_simple_lambda
    # special-case lambda in #apply ?
    assert_equal [:lambda, [], [:+, 1, 1]], BusScheme.eval_string("(lambda () (+ 1 1))")
    BusScheme.eval_string("(define foo (lambda () (+ 1 1)))")
    assert_equal :lambda, BusScheme::SYMBOL_TABLE[:foo].first
    assert_evals_to 2, [:foo]
  end

  def test_lambda_with_arg
    BusScheme.eval_string("(define foo (lambda (x) (+ x 1)))")
    assert_evals_to 2, [:foo, 1]
  end

  def test_lambda_closures
    BusScheme.eval_string "(define foo (lambda (x) ((lambda (y) (+ x y)) (* x 2))))"
    assert_evals_to 3, [:foo, 1]
  end

  private

  def eval(form) # convenience method that accepts string or form
    if form.is_a?(String)
      BusScheme.eval_string(form)
    else
      BusScheme.eval(form)
    end
  end

  def assert_evals_to(expected, form)
    assert_equal expected, eval(form)
  end
end
