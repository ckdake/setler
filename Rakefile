require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  task default: :appraisal
else
  task default: [:test]
end
