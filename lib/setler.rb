require File.join(File.dirname(__FILE__), 'setler', 'version')

module Setler
  class Settings < ActiveRecord::Base
    set_table_name 'settings'
  end
end
