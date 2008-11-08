$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestWebClient < Test::Unit::TestCase
  def test_client
    assert BusScheme['http-method'].body
    eval! "(define root-string \"This is the root of our HTTP!\")
(defresource \"/\" root-string)

(web-get \"http://localhost:2000/\")"
  end
end
