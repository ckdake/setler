require 'test_helper'

class ::SettingsTest < Minitest::Test
  setup_db

  def setup
    ::Settings.create(:var => 'test',  :value => 'foo')
    ::Settings.create(:var => 'test2', :value => 'bar')
  end

  def teardown
    ::Settings.delete_all
    ::Settings.defaults = {}.with_indifferent_access

    ::Preferences.delete_all
    ::Preferences.defaults = {}.with_indifferent_access
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

  def test_get_presence
    ::Settings.truthy = [1,2,3]
    ::Settings.falsy = []
    assert_equal true, ::Settings.truthy?
    assert_equal false, ::Settings.falsy?
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
    assert_nil ::Settings.foo
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

  def test_multithreaded_create
    s1 = Settings.new var: :conflict, value: 1
    s2 = Settings.new var: :conflict, value: 2
    s1.save!
    exc = assert_raises ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid do
        s2.save!
    end
    unless exc.is_a?(ActiveRecord::RecordNotUnique)
      assert exc.message.match(/UNIQUE/)
    end
  end

  def test_complex_serialization
    complex = [1, '2', {"three" => true}]
    ::Settings.complex = complex
    assert_equal complex, ::Settings.complex
  end

  def test_serialization_of_float
    ::Settings.float = 0.01
    ::Settings.reload
    assert_equal 0.01, ::Settings.float
    assert_equal 0.02, ::Settings.float * 2
  end

  def test_all_settings
    assert_equal({ "test2" => "bar", "test" => "foo" }, ::Settings.all_settings)
  end

  def test_destroy
    refute_nil ::Settings.test
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
    assert_equal ::Preferences.all_settings, user.preferences.all_settings
    user.preferences.likes_bacon = true
    user.preferences.really_likes_bacon = true
    assert user.preferences.all_settings['likes_bacon']
    assert !::Settings.all_settings['likes_bacon']
    assert user.preferences.all_settings['really_likes_bacon']
    assert !::Settings.all_settings['really_likes_bacon']
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
    assert_raises Setler::SettingNotFound do
      ::Settings.destroy :not_a_setting
    end
  end

  def test_implementations_are_independent
    ::Preferences.create var: 'test',  value: 'preferences foo'
    ::Preferences.create var: 'test2', value: 'preferences bar'

    refute_match ::Settings.all_settings, ::Preferences.all_settings

    assert_equal 'foo', ::Settings[:test]
    assert_equal 'bar', ::Settings[:test2]
    assert_equal 'preferences foo', ::Preferences[:test]
    assert_equal 'preferences bar', ::Preferences[:test2]
  end

  def test_defaults_are_independent
    ::Settings.defaults[:foo] = false

    refute_equal ::Settings.defaults, ::Preferences.defaults
  end

  def test_destroy_all_on_model_settings_should_not_affect_global_settings
    # Create a global setting
    ::Settings.global_setting = 'global_value'
    
    # Create a user with preferences
    user = User.create name: 'user 1'
    user.preferences.user_pref = 'user_value'
    
    # Verify both exist
    assert_equal 'global_value', ::Settings.global_setting
    assert_equal 'user_value', user.preferences.user_pref
    
    # Destroy all user preferences
    user.preferences.destroy_all
    
    # Global settings should NOT be affected
    assert_equal 'global_value', ::Settings.global_setting, "Global settings should not be destroyed by user.preferences.destroy_all"
    
    # User preferences should be destroyed
    assert_nil user.preferences.user_pref, "User preferences should be destroyed"
  end
  
  def test_destroy_all_on_global_settings_should_not_affect_model_settings
    # Create a global setting
    ::Settings.global_setting = 'global_value'
    
    # Create a user with preferences
    user = User.create name: 'user 1'
    user.preferences.user_pref = 'user_value'
    
    # Verify both exist
    assert_equal 'global_value', ::Settings.global_setting
    assert_equal 'user_value', user.preferences.user_pref
    
    # Destroy all global settings
    ::Settings.destroy_all
    
    # User preferences should NOT be affected
    assert_equal 'user_value', user.preferences.user_pref, "User preferences should not be destroyed by Settings.destroy_all"
    
    # Global settings should be destroyed
    assert_nil ::Settings.global_setting, "Global settings should be destroyed"
  end

  def test_destroy_all_respects_scoping_across_tables
    # Clean up first
    ::Settings.delete_all
    ::Preferences.delete_all
    
    # Create settings in both Settings and Preferences tables
    ::Settings.global_setting = 'global_value'
    ::Settings.another_global = 'another_global_value'
    
    ::Preferences.pref_setting = 'pref_value'
    ::Preferences.another_pref = 'another_pref_value'
    
    # Create a user with scoped preferences
    user = User.create name: 'user 1'
    user.preferences.user_pref = 'user_value'
    user.preferences.another_user_pref = 'another_user_value'
    
    # Destroy all user preferences using the scoped destroy_all
    user.preferences.destroy_all
    
    # Settings should NOT be affected
    assert_equal 2, ::Settings.count, "Settings count should remain 2"
    
    # Global preferences should NOT be affected, only user preferences
    assert_equal 2, ::Preferences.where(thing_type: nil, thing_id: nil).count, "Global preferences should remain 2"
    assert_equal 0, ::Preferences.where(thing_type: 'User', thing_id: user.id).count, "User preferences should be 0"
  end
end
