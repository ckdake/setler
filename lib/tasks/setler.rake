require 'setler/generator'

namespace :setler do
  desc "Generate Setler model and migration (use MODEL=name to specify, defaults to 'settings')"
  task :generate do
    name = ENV['MODEL'] || 'settings'
    generator = Setler::Generator.new(name)
    generator.generate
  end
end
