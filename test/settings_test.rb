require 'test_helper'

class Setler::SettingsTest < Test::Unit::TestCase
  setup_db
  
  def setup
    Setler::Settings.create(:var => 'test',  :value => 'foo')
    Setler::Settings.create(:var => 'test2', :value => 'bar')
  end
  
  def teardown
    Setler::Settings.delete_all
  end
  
  def test_defaults
    Setler::Settings.defaults[:foo] = 'default foo'
    
    assert_equal 'default foo', Setler::Settings.foo
    
    Setler::Settings.foo = 'bar'
    assert_equal 'bar', Setler::Settings.foo
  end
  
  def tests_defaults_false
    Setler::Settings.defaults[:foo] = false
    assert_equal false, Setler::Settings.foo
  end
  
  def test_get
    assert_equal 'foo', Setler::Settings.test
    assert_equal 'bar', Setler::Settings.test2
  end

  def test_update
    Setler::Settings.test = '321'
    assert_equal '321', Setler::Settings.test
  end
  
  def test_create
    Setler::Settings.onetwothree = '123'
    assert_equal '123', Setler::Settings.onetwothree
  end
  
  def test_complex_serialization
    complex = [1, '2', {:three => true}]
    Setler::Settings.complex = complex
    assert_equal complex, Setler::Settings.complex
  end

  def test_serialization_of_float
    Setler::Settings.float = 0.01
    Setler::Settings.reload
    assert_equal 0.01, Setler::Settings.float
    assert_equal 0.02, Setler::Settings.float * 2
  end
  
  def test_all
    assert_equal({ "test2" => "bar", "test" => "foo" }, Setler::Settings.all)
  end
  
  def test_destroy
    assert_not_nil Setler::Settings.test
    Setler::Settings.destroy :test
    assert_nil Setler::Settings.test
  end
end
