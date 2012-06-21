module Setler
  module ActiveRecord
    
    def has_setler(scopename = 'settings')
      define_method scopename do
        Setler::ScopedSettings.for_thing(self, scopename)
      end
      
      # This connects Example.Settings.defaults to to example.defaults
      self.class.instance_eval do
        define_method(scopename.to_s.camelize) do
          eval scopename.to_s.camelize
        end
      end
    end
    
  end
end
