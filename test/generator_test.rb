require 'test_helper'
require 'setler/generator'
require 'tmpdir'
require 'fileutils'

class GeneratorTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('setler_generator_test')
    @original_dir = Dir.pwd
    Dir.chdir(@tmpdir)
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@tmpdir)
  end

  def test_generates_model_file
    generator = Setler::Generator.new('settings')
    generator.generate

    model_path = File.join(@tmpdir, 'app', 'models', 'settings.rb')
    assert File.exist?(model_path), "Model file should exist"
    
    content = File.read(model_path)
    assert_match(/class Settings < Setler::Settings/, content)
  end

  def test_generates_migration_file
    generator = Setler::Generator.new('settings')
    generator.generate

    migration_files = Dir.glob(File.join(@tmpdir, 'db', 'migrate', '*_setler_create_settings.rb'))
    assert_equal 1, migration_files.length, "Should create exactly one migration file"
    
    content = File.read(migration_files.first)
    assert_match(/class SetlerCreateSettings < ActiveRecord::Migration/, content)
    assert_match(/create_table\(:settings\)/, content)
    assert_match(/t\.string\s+:var/, content)
    assert_match(/t\.text\s+:value/, content)
    assert_match(/t\.integer\s+:thing_id/, content)
    assert_match(/t\.string\s+:thing_type/, content)
  end

  def test_generates_custom_named_model
    generator = Setler::Generator.new('featureflags')
    generator.generate

    model_path = File.join(@tmpdir, 'app', 'models', 'featureflags.rb')
    assert File.exist?(model_path), "Custom named model file should exist"
    
    content = File.read(model_path)
    assert_match(/class Featureflags < Setler::Settings/, content)
  end

  def test_generates_custom_named_migration
    generator = Setler::Generator.new('preferences')
    generator.generate

    migration_files = Dir.glob(File.join(@tmpdir, 'db', 'migrate', '*_setler_create_preferences.rb'))
    assert_equal 1, migration_files.length, "Should create custom named migration file"
    
    content = File.read(migration_files.first)
    assert_match(/class SetlerCreatePreferences < ActiveRecord::Migration/, content)
    assert_match(/create_table\(:preferences\)/, content)
  end

  def test_migration_has_proper_indexes
    generator = Setler::Generator.new('settings')
    generator.generate

    migration_files = Dir.glob(File.join(@tmpdir, 'db', 'migrate', '*_setler_create_settings.rb'))
    content = File.read(migration_files.first)
    
    assert_match(/add_index :settings, \[ :thing_type, :thing_id, :var \], unique: true/, content)
    assert_match(/add_index :settings, :var, unique: true, where: "thing_id IS NULL AND thing_type is NULL"/, content)
  end

  def test_migration_has_timestamps
    generator = Setler::Generator.new('settings')
    generator.generate

    migration_files = Dir.glob(File.join(@tmpdir, 'db', 'migrate', '*_setler_create_settings.rb'))
    content = File.read(migration_files.first)
    
    assert_match(/t\.timestamps/, content)
  end

  def test_creates_app_models_directory
    refute Dir.exist?(File.join(@tmpdir, 'app', 'models')), "Directory should not exist before generation"
    
    generator = Setler::Generator.new('settings')
    generator.generate

    assert Dir.exist?(File.join(@tmpdir, 'app', 'models')), "Should create app/models directory"
  end

  def test_creates_db_migrate_directory
    refute Dir.exist?(File.join(@tmpdir, 'db', 'migrate')), "Directory should not exist before generation"
    
    generator = Setler::Generator.new('settings')
    generator.generate

    assert Dir.exist?(File.join(@tmpdir, 'db', 'migrate')), "Should create db/migrate directory"
  end
end
