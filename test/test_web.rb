$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'open-uri'

module BusScheme
  module_function
  def web_server # need to expose this for MockRequest
    @web_server
  end
end

if defined? BusScheme::Resource
  class WebTest < Test::Unit::TestCase
    def setup
      @response = nil

      @die_roboter = "User-agent: *\nAllow: *"
      eval "(resource \"/robots.txt\" \"#{@die_roboter}\")"
      
      eval '(define concourse-splash (quote (html
		(head
		 (title "Concourse"))
		(body
		 (div id "container"
		      (h1 "Welcome to Concourse!")
		      (p "Concourse is ...")
		      (form action "/login"
			    (input type "text" name "email")
			    (input type "password" name "password")
			    (input type "submit" value "Log in")))))))'
      eval '(resource "/" concourse-splash)'
    end
    
    def test_serves_string_resource
      get '/robots.txt'
      assert_response_code 200
      assert_response @die_roboter
    end

    def test_serves_list_resource
      get '/'
      assert_response_code 200
      assert_response "<html>\n  <head>\n    <title>\nConcourse    </title>\n  </head>\n  <body>\n    <div id=\"container\">\n      <h1>\nWelcome to Concourse!      </h1>\n      <form action=\"/login\">\n        <input type=\"text\" name=\"email\">\n        </input>\n        <input type=\"password\" name=\"password\">\n        </input>\n        <input type=\"submit\" value=\"Log in\">\n        </input>\n      </form>\n    </div>\n  </body>\n</html>\n"
    end

    def test_serves_404
      get '/404'
      assert_response_code 404
      assert_response_match /not found/i
    end

    def test_serves_collection_of_resources
      eval '(collection "/numbers" (list ' +
        (1 .. 10).map { |i| eval "(resource \"/#{i}\" \"#{i}\")" }.join(' ') +
        '))'

      get '/numbers'
      assert_response_code 200
      assert_response ""
    end

    def test_serves_collection_of_resources
    end
    
    private
    def get path
      @response = Rack::MockRequest.new(BusScheme.web_server).get(path)
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
