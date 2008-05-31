$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'timeout'

class BusSchemeEvalTest < Test::Unit::TestCase
  def test_eval_empty_list
    assert BusScheme.eval(cons)
#     assert BusScheme.eval(cons('begin'.sym, cons))
#     assert BusScheme.eval_string('()'), "Empty list should be true"
#     assert_evals_to true, "(if () #t #f)"
  end

  def test_eval_number
    assert_evals_to 2, 2
  end

  def test_set_symbol
    BusScheme.current_scope[:hi] = 'hi'
    assert BusScheme.current_scope[:hi]
  end
  
  def test_eval_symbol
    BusScheme.current_scope[:hi.sym] = 13
    assert_evals_to 13, :hi.sym
  end

  def test_eval_string
    assert_evals_to "hi", "\"hi\""
  end

  def test_eval_function_call
    assert_evals_to 2, "(+ 1 1)"
  end

  def test_nested_arithmetic
    assert_evals_to 6, "(+ 1 (+ 1 (* 2 2)))"
  end

  def test_blows_up_with_undefined_symbol
    assert_raises(EvalError) { eval!("undefined-symbol") }
  end

  def test_variable_substitution
    eval! "(define foo 7)"
    assert_evals_to 7, :foo.sym
    assert_evals_to 21, cons(:*.sym, cons(3, cons(:foo.sym)))
  end

  def test_single_quote
    assert_evals_to :foo.sym, "'foo"
    assert_evals_to [:foo.sym, :biz.sym, :bbb.sym].to_list, "'(foo biz bbb)"
  end

  def test_quote
    assert_evals_to :hi.sym, "(quote hi)"
    assert_evals_to [:a.sym, :b.sym, :c.sym].to_list, "'(a b c)"
    assert_evals_to [:a.sym].to_list, "(list 'a)"
    assert_evals_to [:a.sym, :b.sym].to_list, "(list 'a 'b)"
    assert_evals_to [:a.sym, :b.sym, :c.sym].to_list, "(list 'a 'b 'c)"
    assert_evals_to [:+.sym, 2, 3].to_list, "'(+ 2 3)"
  end

  def test_eval_multiple_forms
    assert_raises(EvalError) do
      eval! "(+ 2 2) (undefined-symbol)"
    end
  end

  def test_define_after_load
    eval! "(load \"#{File.dirname(__FILE__)}/../examples/fib.scm\")
(define greeting \"hi\")"
    assert BusScheme.in_scope?(:greeting.sym)
  end

  def test_funcall_list_means_nth
    assert_evals_to 3, "((list 1 2 3) 2)"
  end

#   def test_funcall_vector_means_nth
#     assert_evals_to 3, "((vector 1 2 3) 2)"
#  end

  def test_funcall_hash_means_lookup
    assert_evals_to 3, "((hash (1 1) (2 2) (3 3)) 3)"
  end

  def test_evals_string_ending_in_comment
    assert_evals_to 4, "(+ 2 2)
                        ;; should be four"
  end

#   def test_tail_call_optimization
#     Timeout.timeout(1) do
#       assert_nothing_raised { eval "((lambda (x) (x x)) (lambda (x) (x x)))" }
#     end
#   end
end
