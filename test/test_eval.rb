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
    assert_equal "hi", BusScheme::eval_string("\"hi\"")
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

  #   def test_lambda
  #   end

  private

  def assert_evals_to(expected, form)
    assert_equal expected, BusScheme.eval(form)
  end
end
