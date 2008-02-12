$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class PrimitivesTest < Test::Unit::TestCase
  def test_test_framework
    assert_raises(AssertionFailed) { eval "(assert (= 3 9))"}
    assert_raises(AssertionFailed) { eval "(fail \"EPIC FAIL\")" }
  end

  def test_run_scheme_tests
    BusScheme.load(File.dirname(__FILE__) + '/test_primitives.scm')
  end

  def test_load_file
    eval "(load \"#{File.dirname(__FILE__)}/../examples/fib.scm\")"
    assert Lambda[:fib.sym]
    assert_evals_to 5, "(+ (fib 3) (fib 4))"
    assert_evals_to [1, 1, 2, 3, 5, 8].to_list, "(map fib (list 1 2 3 4 5 6))"
  end

  def test_set!
    clear_symbols(:foo.sym)
    # can only set! existing variables
    assert_raises(BusScheme::EvalError) { eval "(set! foo 7)" }
    eval "(define foo 3)"
    eval "(set! foo 7)"
    assert_evals_to 7, :foo.sym
  end

  def test_consing
    assert_evals_to BusScheme::Cons.new(:foo.sym, :bar.sym), "(cons (quote foo) (quote bar))"
  end

  def test_vectors
    assert_evals_to [1, 2, 3], "#(1 2 3)"
  end

  def test_inspect
    assert_equal "(1)", [1].to_list.inspect
    assert_equal "(1 . 1)", Cons.new(1, 1).inspect
    assert_equal "(1 1 1)", Cons.new(1, Cons.new(1, Cons.new(1))).inspect
    assert_equal "(1 1 1 . 8)", Cons.new(1, Cons.new(1, Cons.new(1, 8))).inspect
  end

  def test_boolean_short_circuit
    assert_evals_to false, "(and #f (assert #f))"
    assert_evals_to true, "(or #t (assert #f))"
  end

  def test_booleans
    assert_evals_to false, '#f'
    assert_evals_to true, '#t'
  end
end
