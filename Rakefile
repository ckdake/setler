# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'

require 'rake'
require 'rake/testtask'
require 'appraisal'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

require 'bundler/gem_tasks'

require 'rake'
require 'appraisal'

desc 'Default'
task :default do
  if ENV['BUNDLE_GEMFILE'] =~ /gemfiles/
    task default: [:test]
  else
    Rake::Task['appraise'].invoke
  end
end

task :appraise do
  exec 'appraisal install && appraisal rake test'
end
