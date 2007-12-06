require 'test_helper'

class SchemancyEvalTest < Test::Unit::TestCase
  def test_eval_number
  end

  def test_eval_string
  end

  def test_eval_function
  end

  def test_eval_function_call
  end

  private

  def assert_evals_to(actual_string, expected)
    assert_equal Schemancy.eval(actual_string), expected
  end
end
