require 'rubygems'

require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rails'
require 'active_record'
require 'minitest/autorun'

require_relative '../lib/setler'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class User < ActiveRecord::Base
  has_setler :preferences
end

class Settings < Setler::Settings
end

class Preferences < Setler::Settings
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :settings do |t|
      t.string :var, :null => false
      t.text   :value, :null => true
      t.integer :thing_id, :null => true
      t.string :thing_type, :limit => 30, :null => true
      t.timestamps
    end
    add_index :settings, [ :thing_type, :thing_id, :var ], :unique => true

    create_table :preferences do |t|
      t.string :var, :null => false
      t.text   :value, :null => true
      t.integer :thing_id, :null => true
      t.string :thing_type, :limit => 30, :null => true
      t.timestamps
    end
    add_index :preferences, [ :thing_type, :thing_id, :var ], :unique => true

    create_table :users do |t|
      t.string :name
    end
  end
end
