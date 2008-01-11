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
    clear_symbols :foo
    eval("(define foo 5)")
    assert_equal 5, BusScheme[:foo]
    eval("(define foo (quote (5 5 5))")
    assert_evals_to [5, 5, 5], :foo
  end

  def test_define_returns_defined_term
    assert_evals_to :foo, "(define foo 2)"
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
    assert_raises(BusScheme::EvalError) { eval("undefined-symbol") }
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
    clear_symbols(:foo)
    # can only set! existing variables
    assert_raises(BusScheme::EvalError) { eval "(set! foo 7)" }
    eval "(define foo 3)"
    eval "(set! foo 7)"
    assert_evals_to 7, :foo
  end

  def test_load_file
    eval "(load \"#{File.dirname(__FILE__)}/foo.scm\")"
    assert_evals_to 3, :foo
  end
end
