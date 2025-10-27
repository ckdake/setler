#!/usr/bin/env ruby
# Standalone generator for Setler - works without Rails
# Usage: ruby -r setler/standalone_generator -e "Setler::StandaloneGenerator.run(ARGV)" <model_name>
# Or: require 'setler/standalone_generator' and call Setler::StandaloneGenerator.run(['model_name'])

require_relative 'generator'

module Setler
  module StandaloneGenerator
    def self.run(args)
      name = args.first || 'settings'
      generator = Setler::Generator.new(name)
      generator.generate
    end
  end
end

# Run the generator if this file is executed directly
if __FILE__ == $0
  Setler::StandaloneGenerator.run(ARGV)
end
