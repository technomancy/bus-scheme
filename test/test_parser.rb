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
    assert_parses_equal "(+ 2 2)", "(+ 2  \n \t    2)"
  end

  #   def test_parses_dotted_cons
  #     assert_parses_to "(22 . 11)", [:cons, 22, 11]
  #     assert_parses_to "((+ 2 2) . 11)", [:cons, [:+, 2, 2], 11]
  #   end

  #   def test_floats
  #     assert_parses_to "44.9", 44.9
  #     assert_parses_to "0.22", 0.22
  #     assert_parses_to ".22", 0.22
  #     assert_parses_to "2.220", 2.22
  #   end

  #   def test_negative_numbers
  #     assert_parses_to "-1", -1
  #     assert_parses_to "-0", 0
  #     assert_parses_to "-02", -2
  #   end

  #   def test_negative_floats
  #     assert_parses_to "-0.22", -0.22
  #     assert_parses_to "-.22", -0.22
  #     assert_parses_to "-0.10", -0.1
  #   end

  #   def test_character_literals
  #     assert_parses_to "?e", "e"
  #     assert_parses_to "?A", "A"
  #     # what else?
  #   end

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

  private

  def assert_parses_to(actual_string, expected)
    assert_equal expected, BusScheme.parse(actual_string)
  end

  def assert_parses_equal(one, two)
    assert_equal BusScheme.parse(one), BusScheme.parse(two)
  end
end
