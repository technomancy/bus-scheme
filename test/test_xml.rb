$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'open-uri'

begin
  require 'hpricot'

  class XmlTest < Test::Unit::TestCase
    def test_single_cons
      assert_equal_xml "<html> </html>", eval("(xml (html))")
    end
    
    def test_singly_nested_list
      assert_equal_xml("<html> <title> </title> </html>",
                       eval("(xml (html (title)))"))
    end

    def test_list_with_string
      assert_equal_xml("<html> <title> Hello </title> </html>",
                       eval("(xml (html (title \"Hello\")))"))

    end

    def test_list_with_symbol
      assert_equal_xml("<a href=\"http://bus-scheme.rubyforge.org\"> Bus Scheme</a>",
                       eval("(xml (a href \"http://bus-scheme.rubyforge.org\" \"Bus Scheme\"))"))
    end

    # TODO: no idea why this puts {} on stdout
    def test_splash_page_generation
      sexp = '(html
		(head
		 (title "Concourse"))
		(body
		 (div id "container"
		      (h1 "Welcome to Concourse!")
		      (p "Concourse is ...")
		      (form action "/login"
			    (input type "text" name "email")
			    (input type "password" name "password")
			    (input type "submit" value "Log in")))))'
      xml_text = "<html> <head> <title> Concourse </title> </head>
<body> <div id=\"container\"> <h1> Welcome to Concourse! </h1>
<form action=\"/login\">
  <input name=\"email\" type=\"text\" />
  <input name=\"password\" type=\"password\" />
  <input type=\"submit\" value=\"Log in\" />
</form>
</div> </body> </html>"
      assert_equal_xml xml_text, eval("(xml #{sexp})")
    end

    private
    def assert_equal_xml(expected, actual, message = nil)
      # TODO: whitespace handling could be better
      assert_equal Hpricot(expected).to_s.gsub(/\s+/, ' ').strip, Hpricot(actual).to_s.gsub(/\s+/, ' ').strip, message
    end
  end

rescue LoadError
  puts "Can't test XML generation without Hpricot; sorry."
end
