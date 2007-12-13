begin
  require 'rubygems'
  gem 'miniunit'
rescue LoadError
  puts "Proceeding with standard test/unit instead of miniunit."
end

$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'
require 'test/unit'
require 'bus_scheme'
