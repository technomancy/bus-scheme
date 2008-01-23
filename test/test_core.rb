$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class CoreTest < Test::Unit::TestCase
  def test_comparison
    assert_evals_to true, "(null? ())"
    assert_evals_to false, "(null? 43)"
    assert_evals_to true, "(> 4 2)"
    assert_evals_to false, "(> 9 13)"
    assert_evals_to true, "(= 4 4)"
    assert_evals_to false, "(= (+ 2 2) 5)"
    assert_evals_to true, "(not #f)"
    assert_evals_to false, "(not #t)"
  end


  def test_string_functions
    assert_evals_to :hi, [:intern, 'hi']
    assert_evals_to 'lo', [:substring, 'hello', 3, 5]
  end
end
