$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'open-uri'

class WebTest < Test::Unit::TestCase
  def test_serves_string_resource
    die_roboter = "User-agent: *\nAllow: *"
    eval "(resource \"/robots.txt\" \"#{die_roboter}\")"
    assert_response die_roboter, 'http://localhost:2000/robots.txt'
  end

  def test_serves_list_resource
    sexp = eval '(define concourse-splash (quote (html
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
    html = ""
    assert_response html, 'http://localhost:2000'
  end

  private
  def assert_response expected, url, message = nil
    assert_equal expected, open(url).read, message
  end
end
