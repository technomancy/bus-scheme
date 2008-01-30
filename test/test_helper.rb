$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'
require 'test/unit'
require 'bus_scheme'

class Test::Unit::TestCase
  # convenience method that accepts string or form
  def eval(form)
    if form.is_a?(String)
      BusScheme.eval_string(form)
    else
      BusScheme.eval_form(form)
    end
  end

  def assert_evals_to(expected, form)
    assert_equal expected, eval(form)
  end

  # remove symbols from all scopes
  def clear_symbols(*symbols)
    [BusScheme::Lambda.scope, BusScheme::SYMBOL_TABLE].compact.map{ |scope| symbols.map{ |sym| scope.delete sym } }
  end
end
