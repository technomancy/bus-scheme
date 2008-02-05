$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'open-uri'

# TODO: figure out a better rubinius heuristic
return unless RUBY_VERSION == '1.8.6' and not "".respond_to? :to_sexp

require 'web'

require "#{File.dirname __FILE__}/../lib/web.rb"

HTML = <<EOH
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head><title>Bus Scheme says Hello!</title></head>
<body>
  <h1>Bus Scheme</h1>
  <p>Bus Scheme is serving <tt>HTTP</tt> and <tt>XHTML</tt>!</p>
</body>
</html>
EOH

class WebTest < Test::Unit::TestCase
  def test_listens_on_specified_port
    eval '(http-listen (lambda (req) "hello world"))'
    assert_equal 'hello world', open('http://localhost:3500/').read
  end

#   def test_returns_html_at_root
#   end
end
