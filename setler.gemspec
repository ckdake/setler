# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "setler/version"

Gem::Specification.new do |s|
  s.name        = "setler"
  s.version     = Setler::VERSION
  s.authors     = ["Chris Kelly"]
  s.email       = ["ckdake@ckdake.com"]
  s.homepage    = "https://github.com/ckdake/setler"
  s.summary     = %q{Settler lets you use the 'Feature Flags' pettern or add settings to models.}
  s.description = %q{Setler is a Gem that lets one easily implement the "Feature Flags" pattern, or add settings to individual models. This is a cleanroom implementation of what the 'rails-settings' gem does. It's been forked all over the place, and my favorite version of it doesn't have any tests and doesn't work with settings associated with models.}

  s.rubyforge_project = "setler"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('activerecord', '>=3.0.0')
  s.add_dependency('rails',        '>=3.0.0')

  s.add_development_dependency('sqlite3')
  s.add_development_dependency('rake')
  s.add_development_dependency('minitest')
end
