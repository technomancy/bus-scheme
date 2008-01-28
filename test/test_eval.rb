$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class BusSchemeEvalTest < Test::Unit::TestCase
  def test_eval_empty_list
    assert_evals_to [], []
    assert_evals_to true, "(if () #t #f)"
  end

  def test_eval_number
    assert_evals_to 2, 2
  end

  def test_set_symbol
    BusScheme::Lambda.scope[:hi] = 'hi'
    assert BusScheme::Lambda.scope[:hi]
  end
  
  def test_eval_symbol
    BusScheme::Lambda.scope[:hi] = 13
    assert_evals_to 13, :hi
  end

  def test_eval_string
    assert_evals_to "hi", "\"hi\""
  end

  def test_eval_function_call
    assert_evals_to 2, [:+, 1, 1]
  end

  def test_nested_arithmetic
    assert_evals_to 6, [:+, 1, [:+, 1, [:*, 2, 2]]]
  end

  def test_blows_up_with_undefined_symbol
    assert_raises(BusScheme::EvalError) { eval("undefined-symbol") }
  end

  def test_variable_substitution
    eval "(define foo 7)"
    assert_evals_to 7, :foo
    assert_evals_to 21, [:*, 3, :foo]
  end

  def test_single_quote
    assert_evals_to :foo, "'foo"
    assert_evals_to [:foo, :biz, :bbb], "'(foo biz bbb)"
  end
end
