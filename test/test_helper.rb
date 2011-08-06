require 'cover_me'
require 'rubygems'

require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'active_record'
require 'test/unit'

require File.join(File.dirname(__FILE__), '..', 'lib', 'setler.rb')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class User < ActiveRecord::Base
  has_setler :preferences
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :settings do |t|
      t.string :var, :null => false
      t.text   :value, :null => true
      t.integer :target_id, :null => true
      t.string :target_type, :limit => 30, :null => true
      t.timestamps
    end
    add_index :settings, [ :target_type, :target_id, :var ], :unique => true
    
    create_table :users do |t|
      t.string :name
    end
  end
end
