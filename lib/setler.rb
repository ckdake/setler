require_relative 'setler/version'
require_relative 'setler/settings'
require_relative 'setler/active_record'

::ActiveRecord::Base.extend Setler::ActiveRecord
