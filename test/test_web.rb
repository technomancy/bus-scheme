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
      assert_response "<html>
  <head>
    <title>
Concourse    </title>
  </head>
  <body>
    <div id=\"container\">
      <h1>
Welcome to Concourse!      </h1>
      <p>
Concourse is ...      </p>
      <form action=\"/login\">
        <input type=\"text\" name=\"email\">
        </input>
        <input type=\"password\" name=\"password\">
        </input>
        <input type=\"submit\" value=\"Log in\">
        </input>
      </form>
    </div>
  </body>
</html>
"
    end

    def test_serves_404
      get '/404'
      assert_response_code 404
      assert_response_match(/not found/i)
    end

    def test_serves_collection_of_resources
      eval '(collection "/numbers" (list ' +
        '(resource "/1" "1")' + 
        '(resource "/2" "2")' + 
        '(resource "/3" "3")' + 
        '))'

      get '/numbers'
      assert_response_code 200
      assert_response_match(/<ul>\s*<li>\s*1\s*<\/li>/)
    end

    def test_link_to_resource
      r = Resource.new('/foobar', "foo bar baz")
      # TODO: this whitespace is getting old
      assert_equal "<a href=\"/foobar\">\nbaz</a>\n", r.link_to('baz')
    end
    
    def test_serves_collection_of_resources_by_regex
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
