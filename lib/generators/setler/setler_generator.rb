require 'rails/generators/migration'

class SetlerGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  argument :name, type: :string, default: "settings"

  source_root File.expand_path('../templates', __FILE__)

  @@migrations = false

  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      if @@migrations
        (current_migration_number(dirname) + 1)
      else
        @@migrations = true
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def generate_model
    template "model.rb", File.join("app/models",class_path,"#{file_name}.rb"), force: true
    migration_template "migration.rb", "db/migrate/setler_create_#{table_name}.rb"
  end
end
