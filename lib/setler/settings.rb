module Setler
  class Settings < ActiveRecord::Base
    serialize :value
    self.abstract_class = true
    
    set_table_name 'settings'
    
    cattr_accessor :defaults
    @@defaults = {}.with_indifferent_access
    
    # Get and Set variables when the calling method is the variable name
    def self.method_missing(method, *args, &block)
      if respond_to?(method)
        super(method, *args, &block)
      else
        method_name = method.to_s
        if method_name.ends_with?("=")
          self.find_or_create_by_var(method_name[0..-2]).update_attribute(:value, args.first)
        else
          self.find_by_var(method_name).try(:value) || @@defaults[method_name]
        end
      end
    end
    
    def self.destroy(var_name)
      var_name = var_name.to_s
      if setting = self.find_by_var(var_name)
        setting.destroy
        true
      else
        raise SettingNotFound, "Setting variable \"#{var_name}\" not found"
      end
    end
    
    def self.all
      Hash[super.collect{ |s| [s.var, s.value] }].merge(@@defaults)
    end
  end
  
end
