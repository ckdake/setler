module Setler
  class ScopedSettings < Settings
    def self.for_thing(object, scopename)
      self.table_name = scopename
      @object = object
      self
    end

    def self.thing_scoped
      self.base_class.where(thing_type: @object.class.base_class.to_s, thing_id: @object.id)
    end

  end
end
