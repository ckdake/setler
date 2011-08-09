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
          # THIS IS BAD
          # thing_scoped.find_or_create_by_var(method_name[0..-2]) should work but doesnt for some reason
          # When @object is present, thing_scoped sets the where scope for the polymorphic association
          # but the find_or_create_by wasn't using the thing_type and thing_id
          thing_scoped.find_or_create_by_var_and_thing_type_and_thing_id(
            method_name[0..-2],
            @object.try(:class).try(:base_class).try(:to_s),
            @object.try(:id)
          ).update_attribute(:value, args.first)
        else
          the_setting = thing_scoped.find_by_var(method_name)
          if the_setting.nil?
            return @@defaults[method_name]
          else
            return the_setting.value
          end
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
      @@defaults.merge(Hash[thing_scoped.all.collect{ |s| [s.var, s.value] }])
    end
    
    def self.thing_scoped
      self.where(thing_type: nil, thing_id: nil)
    end
  end
  
end
