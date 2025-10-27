module Setler
  class ScopedSettings < Settings
    def self.for_thing(object, scopename)
      self.table_name = scopename
      self.defaults = settings_constantize(scopename).defaults
      @object = object
      self
    end

    def self.thing_scoped
      self.base_class.where(thing_type: @object.class.base_class.to_s, thing_id: @object.id)
    end

    # Override destroy_all to only destroy settings for the current object
    def self.destroy_all
      thing_scoped.destroy_all
    end

    # do not use rails default to singularize because setler examples
    # user plural class names
    def self.settings_constantize(scopename)
      Object.const_get(scopename.to_s.camelize)
    end

  end
end
