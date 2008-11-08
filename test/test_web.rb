$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'test_helper_web'
require 'open-uri'

class TestWeb < Test::Unit::TestCase
  def test_serves_404
    get '/404'
    assert_response_code 404
    assert_response_match(/not found/i)
  end

  def test_link_to_resource
    r = Web::Resource.new('/foobar', "foo bar baz")
    assert_equal "<a href=\"/foobar\">\nbaz</a>\n", r.link('baz')
  end

  #     def test_returns_forbidden_when_unauthorized
  #     end
end if defined? BusScheme::Web::Resource

