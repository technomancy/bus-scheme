$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class BusScheme::Lambda
  attr_accessor :body, :formals, :environment
end

class BusSchemeLambdaTest < Test::Unit::TestCase
  def test_simple_lambda
    l = eval("(lambda () (+ 1 1))")
    assert l.is_a?(Lambda)
    assert_equal [[:+.sym, 1, 1]], l.body
    assert_equal [], l.formals

    eval("(define foo (lambda () (+ 1 1)))")
    assert Lambda[:foo.sym].is_a?(Lambda)
    assert_evals_to 2, [:foo.sym]
  end

  def test_lambda_with_arg
    eval("(define foo (lambda (x) (+ x 1)))")
    assert_evals_to 2, [:foo, 1]
  end

  def test_eval_literal_lambda
    assert_evals_to 4, "((lambda (x) (* x x)) 2)"
  end

  def test_lambda_with_incorrect_arity
    eval("(define foo (lambda (x) (+ x 1)))")
    assert_raises(ArgumentError) { assert_evals_to 2, [:foo, 1, 3] }
  end

  def test_lambda_args_dont_stay_in_scope
    clear_symbols(:x, :foo)
    eval("(define foo (lambda (x) (+ x 1)))")
    assert_nil Lambda[:x]
    assert_evals_to 2, [:foo, 1]
    assert_nil Lambda[:x]
  end

  def test_lambda_calls_lambda
    eval "(define f (lambda (x) (+ 3 x)))"
    eval "(define g (lambda (y) (* 3 y)))"
    assert_evals_to 12, "(f (g 3))"
  end

  def test_lambda_closures
    eval "(define foo (lambda (x) ((lambda (y) (+ x y)) (* x 2))))"
    assert_evals_to 3, [:foo, 1]
    eval "(define holder ((lambda (x) (lambda () x)) 2))"
    assert_evals_to 2, "(holder)"
  end

  def test_changes_to_enclosed_variables_are_in_effect_after_lambda_execution
    assert_evals_to 2, "((lambda (x) (begin ((lambda () (set! x 2))) x)) 1)"
  end

  def test_implicit_begin
    assert_evals_to 3, "((lambda () (string->symbol \"hi\") (+ 2 2) (* 1 3)))"
  end

  def test_shadowed_vars_dont_stay_in_scope
    assert_evals_to Cons.new(:a.sym, :b.sym), "(let ((f (let ((x (quote a)))
          (lambda (y) (cons x y)))))
 (let ((x (quote not-a)))
  (f (quote b))))"
  end

  def test_lambda_rest_args
    eval "(define rest (lambda args args))"
    assert_evals_to [:a.sym, :b.sym, :c.sym].to_list, "(rest 'a 'b 'c)"
  end

#   def test_lambdas_know_what_file_they_were_defined_in
#     assert_equal "(primitive)", Lambda[:if.sym].file
    
#     eval "(define fab (lambda () \"warble\"))"
#     assert_equal "(eval)", Lambda[:fab.sym].file

#     filename = File.expand_path("#{File.dirname(__FILE__)}/../examples/fib.scm")
#     eval "(load \"#{filename}\")"
#     assert_equal filename, Lambda[:fib.sym].file
#   end

#   def test_lambdas_know_what_line_they_were_defined_in
#     assert_equal nil, Lambda[:if].line
    
#     filename = File.expand_path("#{File.dirname(__FILE__)}/../examples/fib.scm")
#     eval "(load \"#{filename}\")"
#     assert Lambda.scope[:fib.sym].is_a?(Lambda)
#     assert_equal 1, Lambda.scope[:fib.sym].line

#     eval "#{"\n" * 7} (define fab 'warble)"
#     assert_equal 7, Lambda[:fab.sym].line
#   end
end
