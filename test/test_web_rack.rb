$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'open-uri'

if defined? BusScheme::Web::Resource
  module BusScheme
    module_function
    def Web.server # need to expose this for MockRequest
      @server
    end
  end

  class WebRackTest < Test::Unit::TestCase
    def setup
      @response = nil

      # a very basic rack app in scheme registered at "/simple"
      simple_lambda = '(lambda (env) (quote ("200" ("Content-Type" "text/plain") "This is Simple")))'
      @simple_app = eval!(simple_lambda)
      eval! "(defwebapp \"/simple\" #{simple_lambda})"
      
      # this app returns the SERVER_INFO from the env passed to it
      # TODO: come up with a better method for easily returning these values
      eval! '(defwebapp "/who-am-i" (lambda (env)
                                            (cons "200"
                                                  (cons (quote ("Content-Type" "text/html"))
                                                        (env "PATH_INFO")))))'
    end
    
    def test_app_can_be_called
      @simple_app.call({'PATH_INFO' => '/simple'})
    end
    
    def test_returns_status_code
      get '/simple'
      assert_response_code 200
    end

    def test_returns_content_type
      get '/simple'
      assert_equal 'text/plain', @response.headers['Content-Type']
    end
    
    def test_returns_body
      get '/simple'
      assert_equal 'This is Simple', @response.body
    end

    def test_returning_environment_as_body
      get '/who-am-i'
      assert_equal "/who-am-i", @response.body
      assert_equal 'text/html', @response.headers['Content-Type']
      assert_response_code 200
    end

    private
    
    def get(path)
      @response = mock_request.get(path)
    end

    def put(path, contents)
      @response = mock_request.put(path, { :input => contents })
    end

    def post(path, contents)
      @response = mock_request.post(path, contents)
    end
    
    def delete(path)
      @response = mock_request.delete(path)
    end
        
    def mock_request
      Rack::MockRequest.new(BusScheme::Web.server)
    end
    
    def assert_response expected, message = nil
      raise "No request has been made!" if @response.nil?
      # TODO: make this a little less picky about whitespace etc.
      assert_equal expected, @response.body, message
    end

    def assert_response_match expected, message = nil
      raise "No request has been made!" if @response.nil?
      assert_match expected, @response.body, message
    end

    def assert_response_code expected, message = nil
      raise "No request has been made!" if @response.nil?
      assert_equal expected, @response.status, message
    end
  end
end
