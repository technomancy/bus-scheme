begin
  require 'rubygems'
  gem 'miniunit'
rescue LoadError
  puts "Proceeding with standard test/unit instead of miniunit."
end

$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'
require 'test/unit'
require 'bus_scheme'

def eval(form) # convenience method that accepts string or form
  if form.is_a?(String)
    BusScheme.eval_string(form)
  else
    BusScheme.eval_form(form)
  end
end

def assert_evals_to(expected, form)
  assert_equal expected, eval(form)
end
