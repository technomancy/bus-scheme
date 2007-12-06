require 'test_helper'

class SchemancyParserTest < Test::Unit::TestCase
  def test_parse_numbers
    assert_parses_to "99", 99
  end

  def test_parse_list_of_numbers
    assert_parses_to "(2 2)", [[2, 2]]
  end

  def test_parse_list_of_atoms
    assert_parses_to "(+ 2 2)", [[:+, 2, 2]]
  end

  def test_parse_list_of_atoms_with_string
    assert_parses_to "(+ 2 \"two\")", [[:+, 2, "two"]]
  end

  def test_parse_list_of_nested_sexprs
    assert_parses_to "(+ 2 (+ 2))", [[:+, 2, [:+, 2]]]
  end

  private

  def assert_parses_to(actual_string, expected)
    assert_equal expected, Schemancy.parse(actual_string)
  end
end
