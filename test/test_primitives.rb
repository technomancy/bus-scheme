$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class PrimitivesTest < Test::Unit::TestCase
  def test_test_framework
    assert_raises(AssertionFailed) { eval! "(assert (= 3 9))"}
    assert_raises(AssertionFailed) { eval! "(fail \"EPIC FAIL\")" }
  end

  def test_load_file
    eval! "(load \"#{File.dirname(__FILE__)}/../examples/fib.scm\")"
    assert BusScheme[:fib.sym]
    assert_evals_to 5, "(+ (fib 3) (fib 4))"
    assert_evals_to 8, "(fib 6)"
    assert_evals_to [1, 1, 2, 3, 5, 8].to_list, "(map fib (list 1 2 3 4 5 6))"
  end

  def test_load_path
    examples = File.dirname(__FILE__) + '/../examples/'
    eval! "(set! load-path (cons \"#{examples}\" load-path))"
    eval! "(load \"fib.scm\")"
    assert BusScheme[:fib.sym]
    
    clear_symbols :fib.sym
    current = File.dirname(__FILE__)
    eval! "(set! load-path (cons \"#{current}\" load-path))"
    eval! "(load \"../examples/fib.scm\")"
    assert BusScheme[:fib.sym]
  end

  def test_set!
    clear_symbols(:foo.sym)
    assert ! BusScheme.in_scope?(:foo.sym)
    # can only set! existing variables
    assert_raises(BusScheme::EvalError) { eval! "(set! foo 7)" }
    eval! "(define foo 3)"
    eval! "(set! foo 7)"
    assert_evals_to 7, :foo.sym
  end

  def test_vectors
    assert_evals_to [1, 2, 3], "#(1 2 3)"
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
