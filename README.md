# Setler

Setler is a gem that lets you easily implement the "Feature Flags" pattern or add settings to individual models. This is a cleanroom implementation of what the `rails-settings` gem does. It's been forked all over the place, and my favorite version of it doesn't have any tests and doesn't work with settings associated with models.

[![Test Status](https://github.com/ckdake/setler/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/ckdake/setler/actions/workflows/test.yml)
[![Lint Status](https://github.com/ckdake/setler/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/ckdake/setler/actions/workflows/lint.yml)
[![Gem Version](https://img.shields.io/gem/v/setler.svg)](https://rubygems.org/gems/setler)
[![Gem Downloads](https://img.shields.io/gem/dt/setler.svg)](https://rubygems.org/gems/setler)
[![Required Ruby](https://img.shields.io/gem/ruby/setler.svg)](https://rubygems.org/gems/setler)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

While Setler enables you to create both app-level and model-level settings, they are two separate things and don't mix. For example, if you create defaults for the app, they won't appear as defaults for individual models.

## Setup

Install the gem by adding this to your Gemfile:

```ruby
gem "setler"
```

Generate the model:

```bash
rails g setler <model_name>
```

Run the migration:

```bash
rake db:migrate
```

If you are using the `protected_attributes` gem you must add `attr_protected` to the top of your Setler model.

## Usage

Create/Update settings:

```ruby
# Method calls and []= are synonymous
Featureflags.bacon_dispenser_enabled = true
Settings[:allowed_meats] = ['bacon', 'crunchy bacon']
```

Read settings:

```ruby
Featureflags.bacon_dispenser_enabled # true
Settings[:allowed_meats].include?('bacon')  # true
```

Destroy them:

```ruby
Featureflags.destroy :bacon_dispenser_enabled
Settings.destroy :allowed_meats
```

List all settings:

```ruby
Featureflags.all_settings
Settings.all_settings
```

Set defaults in an initializer with something like:

```ruby
Featureflags.defaults[:bacon_dispenser_enabled] = false
Settings.defaults[:allowed_meats] = ['itsnotbacon']
```

To revert to the default after changing a setting, destroy it. Note: updating the setting to `nil` or `false` no longer makes it the default setting (> 0.0.6), but changes the setting to `nil` or `false`.

Add them to any ActiveRecord object:

```ruby
class User < ActiveRecord::Base
  has_setler :settings
end

user = User.first
user.settings.favorite_meat = :bacon
user.settings.favorite_meat  # :bacon
user.settings.all # { "favorite_meat" => :bacon }
```

TODO: And look them up:

```ruby
User.with_settings_for('favorite_meat') # => scope of users with the favorite_meat setting
```

## Development Environment

Setler includes a ready-to-use Dev Container that provisions Ruby 3.4.7 alongside Bundler 2.4.22. When using VS Code with the Dev Containers extension (or GitHub Codespaces), choose **Reopen in Container** and the setup scripts will run `bundle _2.4.22_ install` so the gem dependencies are available immediately. The container also enables *format on save* with Ruby LSP, YAML, and Markdown tooling preinstalled for a consistent editing experience. Rails 4 support relies on Bundler 1.17.3 and Ruby 2.6; our CI matrix exercises that combination, and you can mirror it locally with a Ruby 2.6 toolchain if needed.

Developing locally? Install the Ruby version pinned in `.ruby-version` and the matching Bundler release, then run:

```bash
gem install bundler -v 2.4.22
bundle _2.4.22_ install
bundle _2.4.22_ exec appraisal rails-5 bundle install
bundle _2.4.22_ exec appraisal rails-6-edge bundle install
```

To run the Rails 4 appraisal locally, switch to Ruby 2.6 and use Bundler 1.17.3, for example: `bundle _1.17.3_ exec appraisal rails-4 bundle install` followed by `bundle _1.17.3_ exec appraisal rails-4 rake test`.

Our GitHub Actions workflow exercises the library against Rails 4.2, 5.2, and 6.1 across the latest patch releases of
Ruby 2.6, 2.7, 3.0, 3.1, 3.2, 3.3, 3.4, and the Ruby 3.5 preview. Rails versions that are unsupported on newer
interpreters are only executed on compatible Rubies, and the Ruby 3.5 job is marked experimental while the release
stabilizes. Ruby 2.6 runs only the Rails 4 appraisal (with Bundler 1.17.3) because newer Bundler releases require Ruby
2.7+, while the Ruby 2.7 job covers Rails 5 and 6 using Bundler 2.4.x and the Ruby 3.x jobs use Bundler 2.5.x.

## AI Assistance

We welcome responsible AI-assisted contributions. Human authors remain accountable for every line added to the
repository—even when an agent drafts the code. Before opening a pull request, confirm that:

- Tests are added or expanded to exercise the behavior you changed.
- `bundle exec rubocop --format progress` passes without disabling cops.
- Relevant Appraisal suites finish cleanly locally or in CI, and any failures are addressed.
- Documentation (including this README) reflects behavior changes when applicable.
- Your contributions are compatabile with the MIT license.

Agents collaborating on this repository follow the automation-focused directions in `AGENTS.md`. Refer to that file
when coordinating with AI tooling.

### Linting

Automated linting runs in CI and locally with `bundle exec rubocop --format progress` (Lint department only by default).

## Gem Development

Getting started is pretty straightforward:

1. Check out the code: `git clone git://github.com/ckdake/setler.git`
1. Install dependencies: `bundle _2.4.22_ install`
1. Install the per-Rails dependencies:

  ```bash
  bundle _2.4.22_ exec appraisal rails-5 bundle install
  bundle _2.4.22_ exec appraisal rails-6-edge bundle install
  ```

1. Run the tests for the supported Rails versions you just installed:

  ```bash
  bundle _2.4.22_ exec appraisal rails-5 rake test
  bundle _2.4.22_ exec appraisal rails-6-edge rake test
  ```

1. Run the linters described above before opening a pull request.

If you'd like to contribute code, make your changes and submit a pull request that includes appropriate tests.

To build the gem: `rake build`

To release a gem to GitHub and RubyGems: `rake release`
