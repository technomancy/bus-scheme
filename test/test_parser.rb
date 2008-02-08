$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class BusSchemeParserTest < Test::Unit::TestCase
  def test_pop_token
    string = "(+ 2 2)"
    assert_equal :'(', BusScheme.pop_token(string)

    assert_equal :'+', BusScheme.pop_token(string)
    assert_equal 2, BusScheme.pop_token(string)
    assert_equal 2, BusScheme.pop_token(string)
    assert_equal :")", BusScheme.pop_token(string)

    string = "\"two\")"
    assert_equal "two", BusScheme.pop_token(string)
    assert_equal ")", string
  end

  def test_tokenize
    assert_equal [:'(', :'+', 2, 2, :')'], BusScheme.tokenize("(+ 2 2)")
    assert_equal [:'(', :'+', 2, :'(', :'+', 22, 2, :')', :')'], BusScheme.tokenize("(+ 2 (+ 22 2))")
    assert_equal [:'(', :plus, 2, 2, :')'], BusScheme.tokenize('(plus 2 2)')
  end

  def test_parse_numbers
    assert_parses_to "99", 99
  end

  def test_parses_strings
    assert_parses_to "\"hello world\"", "hello world"
  end

  def test_parses_two_strings
    assert_parses_to "(concat \"hello\" \"world\")", [:concat, "hello", "world"]
  end

  def test_parse_list_of_numbers
    assert_parses_to "(2 2)", [2, 2]
  end

  def test_parse_list_of_atoms
    assert_parses_to "(+ 2 2)", [:+, 2, 2]
  end

  def test_parse_list_of_atoms_with_string
    assert_parses_to "(+ 2 \"two\")", [:+, 2, "two"]
  end

  def test_parse_list_of_nested_sexprs
    assert_parses_to "(+ 2 (+ 2))", [:+, 2, [:+, 2]]
  end

  def test_parse_list_of_deeply_nested_sexprs
    assert_parses_to "(+ 2 (+ 2 (+ 2 2)))", [:+, 2, [:+, 2, [:+, 2, 2]]]
  end

  def test_parse_two_consecutive_parens_simple
    assert_parses_to "(let ((foo 2)))", [:let, [[:foo, 2]]]
  end

  def test_parse_two_consecutive_parens
    assert_parses_to "(let ((foo 2)) (+ foo 2))", [:let, [[:foo, 2]], [:+, :foo, 2]]
  end

  def test_whitespace_indifferent
    assert_equal 3, BusScheme.pop_token("3 2\n2")
    assert_parses_equal "(+ 2 2)", "(+ 2       2)", "confused by spaces"
    assert_parses_equal "(+ 2 2)", "(+ 2  \t   2)", "confused by tab"
    assert_parses_equal "(+ 2 2)", "(+ 2\n2)", "confused by newline"
  end

  def test_parses_vectors
    assert_equal [:'(', :vector, 1, 2, :')'], BusScheme::tokenize("#(1 2)").flatten
    assert_parses_to  "#(1 2)", [:vector, 1, 2]
    assert_parses_to "#(1 (2 3 4))", [:vector, 1, [2, 3, 4]]
  end
  
#   def test_parses_dotted_cons
#     assert_parses_to "(22 . 11)", [:cons, 22, 11]
#     assert_parses_to "((+ 2 2) . 11)", [:cons, [:+, 2, 2], 11]
#   end

  def test_floats
    assert_parses_to "44.9", 44.9
    assert_parses_to "0.22", 0.22
    assert_parses_to ".22", 0.22
    assert_parses_to "2.220", 2.22
  end

  def test_negative_ints
    assert_parses_to "-1", -1
    assert_parses_to "-0", 0
    assert_parses_to "-02", -2
  end

  def test_negative_floats
    assert_parses_to "-0.22", -0.22
    assert_parses_to "-.22", -0.22
    assert_parses_to "-0.10", -0.1
  end

#   def test_character_literals
#     assert_parses_to "?#e", "e"
#     assert_parses_to "?#A", "A"
#   end
  
  def test_quote
    assert_parses_to "'foo", [:quote, :foo]
    assert_equal [:'(', :quote, :'(', :foo, :bar, :baz, :')', :')'], BusScheme::tokenize("'(foo bar baz)").flatten
    assert_parses_to "'(foo bar baz)", [:quote, [:foo, :bar, :baz]]
    assert_parses_to "'(+ 20 3)", [:quote, [:+, 20, 3]]
  end

  #  have to change normalize_whitespace to not turn newlines into spaces for this to work
  def test_ignore_comments
    assert_parses_to ";; hello", nil
    assert_parses_to "12 ;; comment", 12
    assert_parses_to "(+ 2;; this is a mid-sexp comment
2)", [:+, 2, 2]
  end

  def test_requires_closed_lists
    assert_raises(ParseError) { BusScheme.parse "(+ 2 2" }
    assert_raises(ParseError) { BusScheme.parse "(+ (* 3 4) 2 2" }
  end
  
#   def test_reject_bad_identifiers
#     [".ab3", "14kalt", "-bolt"].each do |identifier|
#       assert_raises(BusScheme::ParseError, "#{identifier} should not be valid") { BusScheme.parse(identifier) }
#     end
#   end

  def test_r5rs_identifiers
    ["lambda", "q", "list->vector", "soup", "+",
     "V17a", "<=?", "a34kTMNs",
     "the-word-recursion-has-many-meanings"].each do |identifier|
      assert_nothing_raised { BusScheme.parse(identifier) }
    end
  end
  
  def test_parse_random_elisp_form_from_my_dot_emacs
    lisp = "(let ((system-specific-config
         (concat \"~/.emacs.d/\"
                 (shell-command-to-string \"hostname\"))))
    (if (file-exists-p system-specific-config)
        (load system-specific-config)))"
    assert_parses_to(lisp,
                     [:let, [[:'system-specific-config',
                              [:concat, "~/.emacs.d/",
                               [:'shell-command-to-string', "hostname"]]]],
                      [:if, [:'file-exists-p', :'system-specific-config'],
                       [:load, :'system-specific-config']]])
   end

  def test_parser_saves_file_info
    tree = BusScheme.parse("(define foo 23)")
    assert_equal "(eval)", tree.cdr.car.file
  end
  
#   def test_accepts_multiline_strings_in_repl
#     # oh crap
#   end
  
  private

  def assert_parses_to(actual_string, expected)
    assert_equal expected.sexp, BusScheme.parse(actual_string)
  end

  def assert_parses_equal(one, two, message = nil)
    assert_equal BusScheme.parse(one), BusScheme.parse(two), message
  end
end
