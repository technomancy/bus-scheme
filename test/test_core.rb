$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class CoreTest < Test::Unit::TestCase
  def test_comparison
    assert_evals_to true, "(null? ())"
    # TODO: nil problems
    # assert_evals_to false, "(null? 43)"
    assert_evals_to true, "(> 4 2)"
    assert_evals_to false, "(> 9 13)"
    assert_evals_to true, "(= 4 4)"
    assert_evals_to false, "(= (+ 2 2) 5)"
    assert_evals_to true, "(not #f)"
    assert_evals_to false, "(not #t)"
  end

  def test_string_functions
    assert_evals_to :hi.sym, ['string->symbol'.sym, 'hi'].sexp
    assert_evals_to 'lo', [:substring.sym, 'hello', 3, 5].sexp
  end

  def test_list_functions
    assert_evals_to :foo.sym, "(car (cons (quote foo) (quote bar)))"
    assert_evals_to :bar.sym, "(cdr (cons (quote foo) (quote bar)))"
    assert_equal(Cons.new(:foo.sym, Cons.new(:bar.sym, nil)),
                 [:foo.sym, :bar.sym].to_list)
    assert_evals_to(Cons.new(2, Cons.new(3, nil)),
                    "(list 2 3)")
    assert_evals_to "bar", "(cadr (list \"foo\" \"bar\"))"
    assert_evals_to [1, :foo.sym].to_list, "(list 1 'foo)"
  end
end
