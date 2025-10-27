# -*- encoding: utf-8 -*-
# stub: rubocop-rspec 2.31.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop-rspec".freeze
  s.version = "2.31.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/rubocop/rubocop-rspec/blob/master/CHANGELOG.md", "documentation_uri" => "https://docs.rubocop.org/rubocop-rspec/", "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Backus".freeze, "Ian MacLeod".freeze, "Nils Gemeinhardt".freeze]
  s.date = "2024-06-07"
  s.description = "Code style checking for RSpec files.\nA plugin for the RuboCop code style enforcing & linting tool.\n".freeze
  s.email = ["johncbackus@gmail.com".freeze, "ian@nevir.net".freeze, "git@nilsgemeinhardt.de".freeze]
  s.extra_rdoc_files = ["MIT-LICENSE.md".freeze, "README.md".freeze]
  s.files = ["MIT-LICENSE.md".freeze, "README.md".freeze]
  s.homepage = "https://github.com/rubocop/rubocop-rspec".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Code style checking for RSpec files".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rubocop>.freeze, ["~> 1.40"])
  s.add_runtime_dependency(%q<rubocop-capybara>.freeze, ["~> 2.17"])
  s.add_runtime_dependency(%q<rubocop-factory_bot>.freeze, ["~> 2.22"])
  s.add_runtime_dependency(%q<rubocop-rspec_rails>.freeze, ["~> 2.28"])
end
