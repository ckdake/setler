require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task default: [:test]

namespace :cover_me do
  desc "Generates and opens code coverage report."
  task :report do
    require 'cover_me'
    CoverMe.complete!
  end
end

task :test do
  Rake::Task['cover_me:report'].invoke
end

task :spec do
  Rake::Task['cover_me:report'].invoke
end
