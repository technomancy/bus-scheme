$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class PrimitivesTest < Test::Unit::TestCase
  def test_booleans
    assert BusScheme::PRIMITIVES.has_key?('#f'.intern)
    assert_evals_to false, '#f'
    assert_evals_to true, '#t'
  end

  def test_arithmetic
    assert_evals_to 2, [:'-', 4, 2]
    assert_evals_to 2, [:'/', 4, 2]
    assert_evals_to 2, [:'*', 1, 2]
  end

  def test_many_args_for_arithmetic
    assert_evals_to 4, [:+, 1, 1, 1, 1]
    assert_evals_to 2, [:*, 1, 2, 1, 1]
  end

  def test_concat
    assert_evals_to "foobar", "(concat \"foo\" \"bar\")"
  end

  def test_eval_quoted_args
    assert_evals_to 23, "(eval '(+ 20 3))"
  end
  
  def test_eval_ruby
    assert_evals_to "foofoofoo", "(ruby \"'foo' * 3\")"
  end

  def test_message_passing
    assert_evals_to 7, "(send 3 (intern \"+\") 4)"
  end

  def test_load_file
    eval "(load \"#{File.dirname(__FILE__)}/../examples/fib.scm\")"
    assert_evals_to 5, "(fib 5)"
  end

  # special forms
  def test_define
    clear_symbols :foo
    eval("(define foo 5)")
    assert_equal 5, BusScheme::Lambda.scope[:foo]
    eval("(define foo (quote (5 5 5)))")
    assert_evals_to [5, 5, 5].to_list, :foo
  end

  def test_define_returns_defined_term
    assert_evals_to :foo, "(define foo 2)"
    assert_equal 2, eval("foo")
  end

  def test_eval_quote
    assert_evals_to [:'+', 2, 2].to_list, [:quote, [:'+', 2, 2]]
  end

  def test_quote
    assert_evals_to :hi, [:quote, :hi]
    assert_evals_to [:a, :b, :c].to_list, "'(a b c)"
    assert_evals_to [:a].to_list, "(list 'a)"
    assert_evals_to [:a, :b].to_list, "(list 'a 'b)"
    assert_evals_to [:a, :b, :c].to_list, "(list 'a 'b 'c)"
    assert_evals_to [:+, 2, 3].to_list, "'(+ 2 3)"
  end

  def test_if
    assert_evals_to 7, [:if, '#f'.intern, 3, 7]
    assert_evals_to 3, [:if, [:>, 8, 2], 3, 7]
  end

  def test_begin
    eval([:begin,
          [:define, :foo, 779],
          9])
    assert_equal 779, BusScheme::SYMBOL_TABLE[:foo]
  end

  def test_set!
    clear_symbols(:foo)
    # can only set! existing variables
    assert_raises(BusScheme::EvalError) { eval "(set! foo 7)" }
    eval "(define foo 3)"
    eval "(set! foo 7)"
    assert_evals_to 7, :foo
  end

  def test_consing
    assert_evals_to BusScheme::Cons.new(:foo, :bar), "(cons (quote foo) (quote bar))"
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

  def test_let
    assert_evals_to 4, "(let ((x 2)
                              (y 2))
                           (+ x y))"

    assert_evals_to 6, "(let ((doubler (lambda (x) (* 2 x)))
                             (x 3))
                           (doubler x))"

    assert_evals_to 6, "(let ((doubler (lambda (x) (* 2 x)))
                             (x 3))
                           x
                           (doubler x))"
  end

  def test_assert
    assert_raises(AssertionFailed) { eval "(assert (= 3 9))"}
  end

  AS_SMALL_AS_POSSIBLE = 19
  def test_as_few_primitives_as_possible
    assert BusScheme::PRIMITIVES.size <= AS_SMALL_AS_POSSIBLE # =)
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

  def test_boolean_short_circuit
    assert_evals_to false, "(and #f (assert #f))"
    assert_evals_to true, "(or #t (assert #f))"
  end
end
