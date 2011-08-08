require 'active_record'

require_relative 'setler/version'
require_relative 'setler/exceptions'
require_relative 'setler/settings'
require_relative 'setler/scoped_settings'
require_relative 'setler/active_record'

::ActiveRecord::Base.extend Setler::ActiveRecord
