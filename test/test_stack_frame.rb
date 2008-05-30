$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestStackFrame < Test::Unit::TestCase
  def setup
    @parent = {:foo => "FOO", :baz => 'BAZ'}
    @h = StackFrame.new({:foo => 'foo', :bar => 'bar'},
                           @parent, eval("(lambda () 1)"))
  end
  
  def test_has_key?
    assert @h.has_key?(:foo)
    assert @h.has_key?(:bar)
    assert @h.has_key?(:baz)

    assert @parent.has_key?(:baz)
    assert @parent.has_key?(:foo)
    assert !@parent.has_key?(:bar)

    assert @h.immediate_has_key?(:foo)
    assert @h.immediate_has_key?(:bar)
    assert !@h.immediate_has_key?(:baz)
  end

  def test_setting_doesnt_alter_parent
    @h[:foo] = "fooooooo"
    assert_equal "fooooooo", @h[:foo]
    assert_equal "FOO", @parent[:foo]
  end
end
