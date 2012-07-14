module Setler
  class ScopedSettings < Settings
    def self.for_thing(object, scopename)
      self.table_name = scopename
      @scoped = true
      @settings_class = scopename.to_s.camelize.constantize
      @object = object
      self
    end

    def self.thing_scoped
      self.base_class.where(thing_type: @object.class.base_class.to_s, thing_id: @object.id)
    end

    def self.defaults
      @settings_class.defaults
    end
  end
end
