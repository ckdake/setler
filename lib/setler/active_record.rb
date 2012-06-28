module Setler
  module ActiveRecord

    def has_setler(scopename = 'settings')
      define_method scopename do
        Setler::ScopedSettings.for_thing(self, scopename)
      end
    end

  end
end
