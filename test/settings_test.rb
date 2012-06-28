require 'test_helper'

class ::SettingsTest < Test::Unit::TestCase
  setup_db

  def setup
    ::Settings.create(:var => 'test',  :value => 'foo')
    ::Settings.create(:var => 'test2', :value => 'bar')
  end

  def teardown
    ::Settings.delete_all
    ::Preferences.delete_all
  end

  def test_defaults
    ::Settings.defaults[:foo] = 'default foo'

    assert_equal 'default foo', ::Settings.foo

    ::Settings.foo = 'bar'
    assert_equal 'bar', ::Settings.foo
  end

  def tests_defaults_false
    ::Settings.defaults[:foo] = false
    assert_equal false, ::Settings.foo
  end

  def test_get
    assert_equal 'foo', ::Settings.test
    assert_equal 'bar', ::Settings.test2
  end

  def test_get_with_array_syntax
    assert_equal 'foo', ::Settings["test"]
    assert_equal 'bar', ::Settings[:test2]
  end

  def test_update
    ::Settings.test = '321'
    assert_equal '321', ::Settings.test
  end

  def test_update_with_false
    ::Settings.test = false
    assert_equal false, ::Settings.test
  end

  def test_update_with_nil_and_default_not_nil
    ::Settings.defaults[:foo] = :test
    ::Settings.foo = nil
    assert_equal nil, ::Settings.foo
  end

  def test_update_with_array_syntax
    ::Settings["test"] = '321'
    assert_equal '321', ::Settings.test

    ::Settings[:test] = '567'
    assert_equal '567', ::Settings.test
  end

  def test_create
    ::Settings.onetwothree = '123'
    assert_equal '123', ::Settings.onetwothree
  end

  def test_complex_serialization
    complex = [1, '2', {:three => true}]
    ::Settings.complex = complex
    assert_equal complex, ::Settings.complex
  end

  def test_serialization_of_float
    ::Settings.float = 0.01
    ::Settings.reload
    assert_equal 0.01, ::Settings.float
    assert_equal 0.02, ::Settings.float * 2
  end

  def test_all
    assert_equal({ "test2" => "bar", "test" => "foo" }, ::Settings.all)
  end

  def test_destroy
    assert_not_nil ::Settings.test
    ::Settings.destroy :test
    assert_nil ::Settings.test
  end

  def test_destroy_reverts_to_default
    ::Settings.defaults[:foo] = :test
    ::Settings[:foo] = :bar

    ::Settings.destroy :foo
    assert_equal :test, ::Settings.foo
  end

  def test_multiple_settings_classes
    ::Settings.testing = '123'
    assert_nil ::Preferences.testing
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
    ::Settings.destroy_all
    user = User.create name: 'user 1'
    assert_equal ::Preferences.all, user.preferences.all
    user.preferences.likes_bacon = true
    user.preferences.really_likes_bacon = true
    assert user.preferences.all['likes_bacon']
    assert !::Settings.all['likes_bacon']
    assert user.preferences.all['really_likes_bacon']
    assert !::Settings.all['really_likes_bacon']
  end

  def test_user_settings_override_defaults
    ::Settings.defaults[:foo] = false
    user = User.create name: 'user 1'
    assert !user.preferences.foo
    user.preferences.foo = true
    assert user.preferences.foo
    user.preferences.foo = false
    assert !user.preferences.foo
  end

  def test_user_preferences_has_defaults
    ::Preferences.defaults[:foo] = true
    user = User.create name: 'user 1'
    assert user.preferences.foo
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
      ::Settings.destroy :not_a_setting
    end
  end

  def test_implementations_are_independent
    ::Preferences.create var: 'test',  value: 'preferences foo'
    ::Preferences.create var: 'test2', value: 'preferences bar'

    assert_not_equal ::Settings.defaults, ::Preferences.defaults

    assert_equal 'foo', ::Settings[:test]
    assert_equal 'bar', ::Settings[:test2]
    assert_equal 'preferences foo', ::Preferences[:test]
    assert_equal 'preferences bar', ::Preferences[:test2]
  end
end
