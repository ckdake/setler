module Setler
  module ActiveRecord
    def has_setler(scopename = 'settings')
      @@scopename = scopename
    end
  end
end
