$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestCons < Test::Unit::TestCase
  def test_inspect
    assert_equal "()", Cons.new(nil, nil).inspect
    assert_equal "(1)", [1].to_list.inspect
    assert_equal "(1 . 1)", Cons.new(1, 1).inspect
    assert_equal "(1 1 1)", Cons.new(1, Cons.new(1, Cons.new(1, nil))).inspect
    assert_equal "(1 1 1 . 8)", Cons.new(1, Cons.new(1, Cons.new(1, 8))).inspect
    assert_equal "(#t #f)", cons(true, cons(false)).inspect
    assert_equal "(#t . #f)", cons(true, false).inspect
  end

  def test_consing
    assert_evals_to BusScheme::Cons.new(:foo.sym, :bar.sym), "(cons (quote foo) (quote bar))"
  end

  def test_cons_to_a
    assert_equal [], cons.to_a
    assert_equal [1], cons(1).to_a
    assert_equal [1,1], cons(1, 1).to_a
    assert_equal [1, 1, 1], cons(1, cons(1, cons(1))).to_a
    assert_equal [cons(1), 1, 1], cons(cons(1), cons(1, cons(1))).to_a
    # TODO - make this work
    # assert_equal [[1], 1, 1], cons(cons(1), cons(1, cons(1))).to_a(true)
  end
  
  def test_eval_and_apply
    assert BusScheme.eval(cons)
    assert cons.to_a
    assert cons.to_a.map! { |arg| eval(arg) }
    # TODO: cons is not nil
    # assert BusScheme.apply(:begin.sym, cons)
  end
  
  def test_equality_of_empty_list
    assert_equal false, eval!("(= () '(1))")
  end

  def test_cons_with_false_cell
    assert_evals_to cons(true, false), "(cons #t #f)"
    # TODO: fix
    # assert_evals_to cons(true, cons(false)), "'(#t #f)"
    # assert_evals_to cons(true, false), "'(#t . #f)"
  end

  def test_caadar_stuff
    list = (0 .. 9).to_a
    assert_equal 2, list.to_list.caddr
    list[3] = ['a', 'b', 'c']
    assert_equal 'b', list.to_list.cadadddr
  end
end
