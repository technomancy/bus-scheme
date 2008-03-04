$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'open-uri'

class WebTest < Test::Unit::TestCase
  def test_serves_resource
    die_roboter = "User-agent: *\nAllow: *"
    eval "(resource \"/robots.txt\" \"#{die_roboter}\")"
    assert_equal die_roboter, open('http://localhost:2000/robots.txt').read
  end
end
