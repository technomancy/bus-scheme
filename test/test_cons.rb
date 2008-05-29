$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestCons < Test::Unit::TestCase
    def test_inspect
    assert_equal "()", Cons.new(nil, nil).inspect
    assert_equal "(1)", [1].to_list.inspect
    assert_equal "(1 . 1)", Cons.new(1, 1).inspect
    assert_equal "(1 1 1)", Cons.new(1, Cons.new(1, Cons.new(1, nil))).inspect
    assert_equal "(1 1 1 . 8)", Cons.new(1, Cons.new(1, Cons.new(1, 8))).inspect
  end

  def test_consing
    assert_evals_to BusScheme::Cons.new(:foo.sym, :bar.sym), "(cons (quote foo) (quote bar))"
  end

  def test_cons_to_a
    assert_equal [], cons.to_a
    assert_equal [1], cons(1).to_a
    assert_equal [1,1], cons(1, 1).to_a
    assert_equal [1, 1, 1], cons(1, cons(1, cons(1))).to_a
    assert_equal [[1], 1, 1], cons(cons(1), cons(1, cons(1))).to_a
  end
end
