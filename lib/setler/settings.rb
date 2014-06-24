module Setler
  class Settings
    class ARSettings < ActiveRecord::Base
      self.table_name = 'settings'
      def self.thing_scoped
        self.base_scope
      end

      def self.base_scope
        self.where(thing_type: nil, thing_id: nil)
      end
      serialize :value
    end

    # Use a Class Instance Variable for defaults. This prevents bleed between different classes that use
    # Setler::Settings. We can't use a cattr_accessor style class variable (@@defaults) here because it
    # bleeds between classes, and we can't use a class variable here (def self.defaults; @defaults; end)
    # because it doesn't share as much as it should.
    class <<self
      def inherited(other)
        puts "OTHER: #{other}"
        other.instance_eval { initialize_class }
        super
      end
      def initialize_class
        @defaults = {}.with_indifferent_access
      end
      attr_accessor :defaults

      def ar_class
        ARSettings
      end
      def thing_scoped
        ar_class.thing_scoped
      end
      def base_scope
        ar_class.base_scope
      end
      def where(*args)
        ar_class.where(*args)
      end
      def delete_all
        ar_class.delete_all
      end
      def destroy_all
        ar_class.delete_all
      end
      def create(*args)
        ar_class.create(*args)
      end
      def reload
        ar_class.thing_scoped.reload
      end
    end


    # Get and Set variables when the calling method is the variable name
    def self.method_missing(method, *args, &block)
      # if ARSettings.respond_to?(method)
        # puts "CALLING ARSETTINGS"
        # ARSettings.send(method, *args, &block)
      # else
        method_name = method.to_s
        if ["table_name="].include?(method_name)
          ar_class.send(method, *args, &block)
        else
          puts "METHOD MISSING: #{method}"
          if method_name.ends_with?("=")
            self[method_name[0..-2]] = args.first
          else
            self[method_name]
          end
        end
      # end
    end

    def self.[](var)
      the_setting = thing_scoped.where(var: var.to_s).first
      if the_setting.present?
        the_setting.value
      else
        if @scoped
          the_setting = base_scope.where(var: var.to_s).first
          the_setting.present? ? the_setting.value : defaults[var]
        else
          defaults[var]
        end
      end
    end

    def self.[]=(var, value)
      thing_scoped.find_or_create_by(
        var: var.to_s
      ).update_attribute(:value, value)
    end

    def self.destroy(var_name)
      var_name = var_name.to_s
      if setting = self.where(var: var_name).first
        setting.destroy
        true
      else
        raise SettingNotFound, "Setting variable \"#{var_name}\" not found"
      end
    end

    def self.all
      defaults.merge(Hash[thing_scoped.collect{ |s| [s.var, s.value] }])
    end

  end
end
