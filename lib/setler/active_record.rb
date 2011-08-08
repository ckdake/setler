module Setler
  module ActiveRecord
    
    def has_setler(scopename = 'settings')
      define_method scopename do
        Setler::ScopedSettings.for_thing(self)
      end
      
      define_method "#{scopename}=" do |hash|
        hash.each do |key,value|
          Setler::Settings.find_or_create_by_thing_id_and_thing_type_and_var(
            self.id,
            self.class,
            key,
            value: value
          )
        end
      end
    end
    
  end
end
