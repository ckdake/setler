# Require Rails version if available
begin
  require 'rails/version'
rescue LoadError
  # Rails not available - this is fine for non-Rails projects
end

module Setler
  class Settings < ActiveRecord::Base
    serialize :value
    self.abstract_class = true

    def self.defaults
      @defaults ||= default_hash
    end

    def self.defaults=(defaults)
      @defaults = to_indifferent_hash(defaults)
    end

    # Rails 3 compatibility
    if defined?(Rails) && Rails::VERSION::MAJOR == 3
      attr_accessible :var, :value

      def self.all
        warn '[DEPRECATED] Setler::Settings#all is deprecated. Please use #all_settings'
        all_settings
      end
    end

    # Get and Set variables when the calling method is the variable name
    def self.method_missing(method, *args, &block)
      if respond_to?(method)
        super(method, *args, &block)
      else
        method_name = method.to_s
        if method_name.end_with?("=")
          self[method_name[0..-2]] = args.first
        elsif method_name.end_with?("?")
          self[method_name[0..-2]].present?
        else
          self[method_name]
        end
      end
    end

    def self.[](var)
      the_setting = thing_scoped.find_by_var(var.to_s)
      the_setting.present? ? the_setting.value : defaults[var]
    end

    def self.[]=(var, value)
      # THIS IS BAD
      # thing_scoped.find_or_create_by_var(method_name[0..-2]) should work but doesnt for some reason
      # When @object is present, thing_scoped sets the where scope for the polymorphic association
      # but the find_or_create_by wasn't using the thing_type and thing_id
      if defined?(Rails) && Rails::VERSION::MAJOR == 3
        thing_scoped.find_or_create_by_var_and_thing_type_and_thing_id(
          var.to_s,
          @object.try(:class).try(:base_class).try(:to_s),
          @object.try(:id)
        ).update({ :value => value })
      else
        thing_scoped.find_or_create_by(
          var: var.to_s,
          thing_type: @object.try(:class).try(:base_class).try(:to_s),
          thing_id: @object.try(:id)
        ).update({ :value => value })
      end
    end

    def self.destroy(var_name)
      var_name = var_name.to_s
  if (setting = self.find_by_var(var_name))
        setting.destroy
        true
      else
        raise SettingNotFound, "Setting variable \"#{var_name}\" not found"
      end
    end

    def self.all_settings
      defaults.merge(Hash[thing_scoped.all.collect{ |s| [s.var, s.value] }])
    end

    def self.thing_scoped
      self.where(thing_type: nil, thing_id: nil)
    end

    # Create a hash with indifferent access (works with or without Rails)
    def self.default_hash
      if defined?(ActiveSupport::HashWithIndifferentAccess)
        {}.with_indifferent_access
      else
        IndifferentHash.new
      end
    end
    private_class_method :default_hash

    def self.to_indifferent_hash(hash)
      if defined?(ActiveSupport::HashWithIndifferentAccess)
        hash.with_indifferent_access
      else
        IndifferentHash.new.merge(hash)
      end
    end
    private_class_method :to_indifferent_hash
  end

  # Simple hash with indifferent access for non-Rails environments
  # Allows accessing hash values with both string and symbol keys
  class IndifferentHash < Hash
    def [](key)
      super(convert_key(key))
    end

    def []=(key, value)
      super(convert_key(key), value)
    end

    def merge(other)
      dup.merge!(other)
    end

    def merge!(other)
      other.each { |k, v| self[k] = v }
      self
    end

    private

    def convert_key(key)
      key.to_s
    end
  end
end
