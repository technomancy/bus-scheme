$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestMacros < Test::Unit::TestCase
  def test_let
    assert_evals_to 2, "(let ((n 2)) n)"
    assert_evals_to 5, "(let ((n 2) (m 3)) (+ n m))"
    assert_evals_to 4, "(let ((x 2)
                              (y 2))
                          (+ x y))"
    assert_evals_to 6, "(let ((doubler (lambda (x) (* 2 x)))
                              (x 3))
                          (doubler x))"
  end

  def test_shadowed_vars_dont_stay_in_scope
    assert_evals_to Cons.new(:a.sym, :b.sym), "(let ((f (let ((x (quote a)))
          (lambda (y) (cons x y)))))
 (let ((x (quote not-a)))
  (f (quote b))))"
  end

  def test_booleans
    eval "(assert-equal #t (and #t #t))
(assert-equal #f (and #t #f))
(assert-equal #f (and #f #t))
(assert-equal #f (and #f #f))

(assert-equal #t (or #t #t))
(assert-equal #t (or #t #f))
(assert-equal #t (or #f #t))
(assert-equal #f (or #f #f))"
  end

  def test_boolean_short_circuit
    assert_evals_to false, "(and #f (assert #f))"
    assert_evals_to true, "(or #t (assert #f))"
  end
end
