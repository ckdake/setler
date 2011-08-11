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

  def test_get_with_array_syntax
    assert_equal 'foo', Setler::Settings["test"]
    assert_equal 'bar', Setler::Settings[:test2]
  end

  def test_update
    Setler::Settings.test = '321'
    assert_equal '321', Setler::Settings.test
  end

  def test_update_with_array_syntax
    Setler::Settings["test"] = '321'
    assert_equal '321', Setler::Settings.test

    Setler::Settings[:test] = '567'
    assert_equal '567', Setler::Settings.test
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
  
  def test_user_has_setler
    user = User.create name: 'user 1'
    assert_nil user.preferences.likes_bacon
    user.preferences.likes_bacon = true
    assert user.preferences.likes_bacon
    user.preferences.destroy :likes_bacon
    assert_nil user.preferences.likes_bacon
  end
  
  def test_user_settings_all
    Setler::Settings.destroy_all
    user = User.create name: 'user 1'
    assert_equal Setler::Settings.all, user.preferences.all
    user.preferences.likes_bacon = true
    user.preferences.really_likes_bacon = true
    assert user.preferences.all['likes_bacon']
    assert !Setler::Settings.all['likes_bacon']
    assert user.preferences.all['really_likes_bacon']
    assert !Setler::Settings.all['really_likes_bacon']
  end
  
  def test_user_settings_override_defaults
    Setler::Settings.defaults[:foo] = false
    user = User.create name: 'user 1'
    assert !user.preferences.foo
    user.preferences.foo = true
    assert user.preferences.foo
    user.preferences.foo = false
    assert !user.preferences.foo
  end
  
  # def test_user_has_settings_for
  #   user1 = User.create name: 'awesome user'
  #   user2 = User.create name: 'bad user'
  #   user1.preferences.likes_bacon = true
  #   assert_equal 1, User.with_settings_for('likes_bacon').count
  #   assert_equal user1, User.with_settings_for('likes_bacon').first
  # end

  def test_destroy_when_setting_does_not_exist
    assert_raise Setler::SettingNotFound do
      Setler::Settings.destroy :not_a_setting
    end
  end
end
