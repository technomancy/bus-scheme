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

  def test_list_functions
    assert_evals_to :foo, "(car (cons (quote foo) (quote bar)))"
    assert_evals_to :bar, "(cdr (cons (quote foo) (quote bar)))"
    assert_equal(Cons.new(:foo, Cons.new(:bar, nil)),
                 [:foo, :bar].to_list)
    assert_evals_to(Cons.new(2, Cons.new(3, nil)),
                    "(list 2 3)")
    assert_evals_to "bar", "(cadr (list \"foo\" \"bar\")"
    assert_evals_to [1, :foo].to_list, "(list 1 'foo)"
  end

  def test_boolean_logic
    assert_evals_to true, "(and #t #t)"
    assert_evals_to false, "(and #t #f)"
    assert_evals_to false, "(and #f #t)"
    assert_evals_to false, "(and #f #f)"

    assert_evals_to true, "(or #t #t)"
    assert_evals_to true, "(or #t #f)"
    assert_evals_to true, "(or #f #t)"
    assert_evals_to false, "(or #f #f)"
  end

#   def test_boolean_short_circuit
#     assert_evals_to false, "(and #f (assert #f))"
#     assert_evals_to true, "(or #t (assert #f))"
#   end
end
