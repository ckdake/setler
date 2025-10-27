require 'fileutils'
require 'erb'

module Setler
  class Generator
    attr_reader :name, :model_name, :table_name, :migration_name, :timestamp

    def initialize(name = 'settings')
      @name = name
      @model_name = name.capitalize
      @table_name = name.downcase
      @timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
      @migration_name = "setler_create_#{table_name}"
    end

    def generate
      create_model
      create_migration
      print_instructions
    end

    private

    def create_model
      model_path = File.join('app', 'models', "#{name}.rb")
      FileUtils.mkdir_p(File.dirname(model_path))
      
      File.write(model_path, model_template)
      puts "Created model: #{model_path}"
    end

    def create_migration
      migration_dir = File.join('db', 'migrate')
      FileUtils.mkdir_p(migration_dir)
      
      migration_file = File.join(migration_dir, "#{timestamp}_#{migration_name}.rb")
      File.write(migration_file, migration_template)
      puts "Created migration: #{migration_file}"
    end

    def model_template
      "class #{model_name} < Setler::Settings\nend\n"
    end

    def migration_template
      <<~RUBY
        class #{migration_class_name} < ActiveRecord::Migration#{migration_version}
          def self.up
            create_table(:#{table_name}) do |t|
              t.string  :var, null: false
              t.text    :value, null: true
              t.integer :thing_id, null: true
              t.string  :thing_type, limit: 30, null: true
              t.timestamps
            end

            add_index :#{table_name}, [ :thing_type, :thing_id, :var ], unique: true
            add_index :#{table_name}, :var, unique: true, where: "thing_id IS NULL AND thing_type is NULL"
          end

          def self.down
            drop_table :#{table_name}
          end
        end
      RUBY
    end

    def migration_class_name
      migration_name.split('_').map(&:capitalize).join
    end

    def migration_version
      # Add version bracket for Rails 5+
      # Try to detect ActiveRecord version if available
      begin
        require 'active_record' unless defined?(ActiveRecord)
        
        if defined?(Rails) && Rails.version.to_f >= 5.0
          "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
        elsif defined?(ActiveRecord::VERSION) && ActiveRecord::VERSION::MAJOR >= 5
          "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
        else
          ""
        end
      rescue LoadError
        # If ActiveRecord is not available, default to no version bracket
        # User can manually add it if needed
        ""
      end
    end

    def print_instructions
      puts "\nSetler files generated successfully!"
      puts "\nNext steps:"
      puts "1. Run your migrations: rake db:migrate"
      puts "2. Use your new settings class: #{model_name}.foo = 'bar'"
    end
  end
end
