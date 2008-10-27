require File.dirname(__FILE__) + '/test_helper'

class TestPrimitives < Test::Unit::TestCase
  def test_test_framework
    assert_raises(AssertionFailed) { eval_either "(assert (= 3 9))"}
    assert_raises(AssertionFailed) { eval_either "(fail \"EPIC FAIL\")" }
  end

  def test_load_file
    eval_either "(load \"#{File.dirname(__FILE__)}/../examples/fib.scm\")"
    assert BusScheme[:fib.sym]
    assert_evals_to 5, "(+ (fib 3) (fib 4))"
    assert_evals_to 8, "(fib 6)"
    assert_evals_to [1, 1, 2, 3, 5, 8].to_list, "(map fib (list 1 2 3 4 5 6))"
  end

  def test_load_path
    examples = File.dirname(__FILE__) + '/../examples/'
    eval_either "(set! load-path (cons \"#{examples}\" load-path))"
    eval_either "(load \"fib.scm\")"
    assert BusScheme[:fib.sym]

    clear_symbols :fib.sym
    current = File.dirname(__FILE__)
    eval_either "(set! load-path (cons \"#{current}\" load-path))"
    eval_either "(load \"../examples/fib.scm\")"
    assert BusScheme[:fib.sym]
  end

  def test_set!
    clear_symbols(:foo.sym)
    assert ! BusScheme.in_scope?(:foo.sym)
    # can only set! existing variables
    assert_raises(BusScheme::EvalError) { eval_either "(set! foo 7)" }
    eval_either "(define foo 3)"
    eval_either "(set! foo 7)"
    assert_evals_to 7, :foo.sym
  end

  def test_vectors
    assert_evals_to [1, 2, 3], "#(1 2 3)"
  end

  def test_inspect
    assert_equal "()", Cons.new(nil, nil).inspect
    assert_equal "(1)", [1].to_list.inspect
    assert_equal "(1 . 1)", Cons.new(1, 1).inspect
    assert_equal "(1 1 1)", Cons.new(1, Cons.new(1, Cons.new(1, nil))).inspect
    assert_equal "(1 1 1 . 8)", Cons.new(1, Cons.new(1, Cons.new(1, 8))).inspect
  end

  def test_booleans
    assert_evals_to false, '#f'
    assert_evals_to true, '#t'
  end
end
