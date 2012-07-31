module Setler
  class Settings < ActiveRecord::Base
    serialize :value
    self.abstract_class = true

    cattr_accessor :defaults
    @@defaults = {}.with_indifferent_access

    # Get and Set variables when the calling method is the variable name
    def self.method_missing(method, *args, &block)
      if respond_to?(method)
        super(method, *args, &block)
      else
        method_name = method.to_s
        if method_name.ends_with?("=")
          self[method_name[0..-2]] = args.first
        else
          self[method_name]
        end
      end
    end

    def self.[](var)
      the_setting = thing_scoped.find_by_var(var.to_s)
      the_setting.present? ? the_setting.value : @@defaults[var]
    end

    def self.[]=(var, value)
      # THIS IS BAD
      # thing_scoped.find_or_create_by_var(method_name[0..-2]) should work but doesnt for some reason
      # When @object is present, thing_scoped sets the where scope for the polymorphic association
      # but the find_or_create_by wasn't using the thing_type and thing_id
      thing_scoped.find_or_create_by_var_and_thing_type_and_thing_id(
        var.to_s,
        @object.try(:class).try(:base_class).try(:to_s),
        @object.try(:id)
      ).update_attributes({ :value => value })
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
