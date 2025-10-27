# Agent Playbook

This file gives coding agents the context they need to work in the Setler repo. Follow every
instruction here unless the user provides something more specific.

## Project Snapshot

- Setler is a Ruby gem that layers application and model settings on top of Active Record.
- The codebase supports Rails 4.2, 5.2, and 6.1 through Appraisal-managed gemfiles.
- Default container Ruby is 3.4.7 with Bundler 2.4.22; CI also exercises Ruby 2.6 through 3.5.

## Environment Setup

- Install gems with `bundle _2.4.22_ install` unless instructed to target another Ruby.
- For appraisal-specific installs use `bundle _2.4.22_ exec appraisal rails-5 bundle install` and
  `bundle _2.4.22_ exec appraisal rails-6-edge bundle install`.
- Rails 4 appraisal requires Ruby 2.6 + Bundler 1.17.3; do not attempt it unless explicitly asked.

## Required Checks

- Run `bundle exec rubocop --format progress` before finishing any task that changes Ruby code.
- Run the relevant Appraisal test commands, for example:
  - `bundle _2.4.22_ exec appraisal rails-5 rake test`
  - `bundle _2.4.22_ exec appraisal rails-6-edge rake test`
- Add or update regression tests when you change behavior. Never lower coverage thresholds.
- Document doc-only edits in the README or changelog when behavior changes.

## Coding Conventions

- Stay with ASCII unless a file already uses Unicode and it is required for the fix.
- Keep comments minimal; only add them when the code is non-obvious.
- Do not revert or overwrite user edits you did not author.
- Prefer existing patterns in `lib/setler/*.rb` and follow established Rails style.

## Workflow Expectations

- Break work into small commits and reference affected files in explanations.
- If tests or lint fail, fix the underlying issue instead of muting the check.
- Mention any commands you could not run so the human can follow up.
- When unsure about product intent or cross-file impacts, ask the user before proceeding.

## Safety & Data

- Only read and write repository content and publicly available documentation.
- Never introduce secrets, tokens, or proprietary data into prompts or files.
- Respect third-party licenses; avoid copying large blocks from external sources.
