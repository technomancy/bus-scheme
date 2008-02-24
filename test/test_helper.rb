$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'
require 'test/unit'
require 'bus_scheme'

module BusScheme
  def self.reset_stack
    @@stack = []
  end
end

class BusScheme::Lambda
  attr_accessor :body, :formals, :enclosing_scope
end

class RecursiveHash
  attr_reader :parent
end

class Test::Unit::TestCase
  include BusScheme

  # convenience method that accepts string or form
  def eval(form)
    begin
      if form.is_a?(String)
        BusScheme.eval_string(form)
      else
        BusScheme.eval(form)
      end
    rescue => e
      BusScheme.reset_stack
      raise e
    end
  end

  def assert_evals_to(expected, form)
    assert_equal expected, eval(form)
  end

  # remove symbols from all scopes
  def clear_symbols(*symbols)
    [BusScheme.current_scope, BusScheme::SYMBOL_TABLE].compact.map{ |scope| symbols.map{ |sym| scope.delete sym } }
  end
end
