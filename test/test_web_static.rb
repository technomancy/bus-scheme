$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'test_helper_web'
require 'open-uri'

class TestWebStatic < Test::Unit::TestCase
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
end if defined? BusScheme::Web::Resource
