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
    eval "(define hi 13)"
    assert_evals_to 13, :hi
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
    BusScheme.clear_symbols :foo
    eval("(define foo 5)")
    assert_equal 5, BusScheme[:foo]
    eval("(define foo (quote (5 5 5))")
    assert_evals_to [5, 5, 5], :foo
  end

  def test_define_returns_defined_term
    assert_evals_to :foo, "(define foo 2)"
    # can't use the eval convenience testing method since it assumes strings are unparsed
    assert_equal 2, eval("foo")
  end

  def test_string_primitives
    assert_evals_to :hi, [:intern, 'hi']
    assert_evals_to 'helloworld', [:concat, 'hello', 'world']
    assert_evals_to 'lo', [:substring, 'hello', 3, -1]
  end

  def test_booleans
    assert_evals_to false, '#f'
    assert_evals_to true, '#t'
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
    assert_raises(RuntimeError) { eval("undefined-symbol") }
  end

  def test_variable_substitution
    eval "(define foo 7)"
    assert_evals_to 7, :foo
    assert_evals_to 21, [:*, 3, :foo]
  end

  def test_if
    assert_evals_to 7, [:if, '#f'.intern, 3, 7]
    assert_evals_to 3, [:if, [:>, 8, 2], 3, 7]
  end

  def test_begin
    eval([:begin,
          [:define, :foo, 779],
          9])
    assert_equal 779, BusScheme[:foo]
  end

  def test_set!
    # i dunno... what does set! do? how's it different from define?
  end

  def test_simple_lambda
    assert_equal [:lambda, [], [:+, 1, 1]], eval("(lambda () (+ 1 1))")
    eval("(define foo (lambda () (+ 1 1)))")
    assert_equal :lambda, BusScheme[:foo].first
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
    BusScheme.clear_symbols(:x, :foo)
    eval("(define foo (lambda (x) (+ x 1)))")
    assert !BusScheme.in_scope?(:x)
    assert_evals_to 2, [:foo, 1]
    assert !BusScheme.in_scope?(:x)
  end

  #   def test_lexical_scoping
  #     assert_raises(BusScheme::EvalError) do
  #       eval "???"
  #     end
  #   end

  #   def test_lambda_closures
  #     eval "(define foo (lambda (x) ((lambda (y) (+ x y)) (* x 2))))"
  #     assert_evals_to 3, [:foo, 1]
  #   end

  #   def test_load_file
  #     eval "(load \"#{File.dirname(__FILE__)}/foo.scm\")"
  #     assert_evals_to 3, :foo
  #   end

  private

  def eval(form) # convenience method that accepts string or form
    if form.is_a?(String)
      BusScheme.eval_string(form)
    else
      BusScheme.eval_form(form)
    end
  end

  def assert_evals_to(expected, form)
    assert_equal expected, eval(form)
  end
end
