$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'test_helper_web'
require 'open-uri'

class TestWebLambda < Test::Unit::TestCase
  def setup
    @response = nil
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

  def test_lambda_resource
    get '/time'
    assert_response_code 200
    assert_response_match /\d\d-\d\d-\d\d \d\d:\d\d/
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
end if defined? BusScheme::Web::Resource
