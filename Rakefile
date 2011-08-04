require 'rubygems'
require 'bundler'
require 'rake'

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
  test.warning = true
end

task default: [:test]

