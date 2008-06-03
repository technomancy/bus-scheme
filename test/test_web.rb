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

  class WebTest < Test::Unit::TestCase
    def setup
      @response = nil

      @die_roboter = "User-agent: *\nAllow: *"
      eval! "(defresource \"/robots.txt\" \"#{@die_roboter}\")"
      
      eval! '(define concourse-splash (quote (html
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
      eval! '(defresource "/" concourse-splash)'

      eval! '(defresource "/time" (lambda (env) (send (now) (quote to_s))))'

      # a very basic rack app in scheme registered at "/simple"
      simple_lambda = '(lambda (env) (quote ("200" ("Content-Type" "text/plain") "This is Simple")))'
      @simple_app = eval!(simple_lambda)
      eval! "(defwebapp \"/simple\" #{simple_lambda})"
      
      # this app returns the SERVER_INFO from the env passed to it
      # TODO: come up with a better method for easily returning these values
      eval! '(defwebapp "/who-am-i" (lambda (env)
                                            (list "200" (quote ("Content-Type" "text/html")) (env "PATH_INFO"))))'
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
        <input name=\"email\" type=\"text\">
        </input>
        <input name=\"password\" type=\"password\">
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

    def test_link_to_resource
      r = Web::Resource.new('/foobar', "foo bar baz")
      assert_equal "<a href=\"/foobar\">\nbaz</a>\n", r.link('baz')
    end

    def test_lambda_resource
      get '/time'
      assert_response_code 200
      assert_response_match /\d\d-\d\d-\d\d \d\d:\d\d/
    end

    def test_puts_existing_resource
      put '/robots.txt', "\"User-agent: *\nDeny: *\""
      assert_response_code 201
      assert_response_match /Deny/
      
      get '/robots.txt'
      assert_response_code 200
      assert_response_match /Deny/
    end

    def test_puts_new_resource
      put '/die_roboter.txt', "\"Das-User-Agent: *\nNein: *\""
      assert_response_code 201
      assert_response_match /Nein/

      get '/die_roboter.txt'
      assert_response_code 200
      assert_response_match /Nein/

      put '/my-crazy-list', '(ul (li "hey dood") (li "second item"))'
      assert_response_code 201
      assert_response "<ul>\n  <li>\nhey dood  </li>\n  <li>\nsecond item  </li>\n</ul>\n"
    end

    def test_deletes_resource
      delete '/robots.txt'
      assert_response_code 302
      get '/robots.txt'
      assert_response_code 404
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

#     def test_returns_forbidden_when_unauthorized
#     end

    def test_client
      assert BusScheme['http-method'].body
      eval! "(define root-string \"This is the root of our HTTP!\")
(defresource \"/\" root-string)

(web-get \"http://localhost:2000/\")"
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
