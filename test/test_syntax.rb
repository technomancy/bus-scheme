require File.dirname(__FILE__) + '/test_helper'

class TestSyntax < Test::Unit::TestCase
  def test_definition
    assert_kind_of SyntaxRules, eval_either('(syntax-rules () ())')
    assert_kind_of Primitive, BusScheme['define-syntax'.sym]
    eval_either('(define-syntax my-syntax (syntax-rules ()))')
    assert_kind_of SyntaxRules, BusScheme['my-syntax'.sym]
  end

  def test_find_matching_rule
    eval_either('(define-syntax my-syntax (syntax-rules ()
                          ((_) empty)
                          ((_ e) symbol)
                          ((_ e1 e2) list)
                          ((_ e1 (e2)) nested-list)))')
    assert_matching_rule 'empty', 'my-syntax', '()'
    assert_matching_rule 'symbol', 'my-syntax', '(hi)'
    assert_matching_rule 'list', 'my-syntax', '(hi there)'
    assert_matching_rule 'nested-list', 'my-syntax', '(hi (there))'
  end

  def test_let
    assert BusScheme.in_scope?(:let.sym)
    assert BusScheme[:let.sym].special_form
    assert_evals_to 2, "(let ((n 2)) n)"
    assert_evals_to 5, "(let ((n 2) (m 3)) (+ n m))"
    assert_evals_to 4, "(let ((x 2)
                              (y 2))
                          (+ x y))"
    assert_evals_to 6, "(let ((doubler (lambda (x) (* 2 x)))
                              (x 3))
                          (doubler x))"
  end

  #   def test_shadowed_vars_dont_stay_in_scope
  #     assert_evals_to Cons.new(:a.sym, :b.sym), "(let ((f (let ((x (quote a)))
  #           (lambda (y) (cons x y)))))
  #  (let ((x (quote not-a)))
  #   (f (quote b))))"
  #   end

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
    assert_evals_to true, "(or #t (assert #f))"
    assert_evals_to false, "(and #f (assert #f))"
  end

  def assert_matching_rule(expected, rule, value)
    assert_equal(expected.sym,
                 BusScheme[rule.sym].transform(parse(value)))
  end
end
