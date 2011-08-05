require 'rails'

module Setler
  class Railtie < Rails::Railtie
    initializer "setler.active_record" do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.extend Setler::ActiveRecord
      end
    end
  end
end
