# frozen_string_literal: true

require_relative "lib/rspec/armour/version"

Gem::Specification.new do |spec|
  spec.name = "rspec-armour"
  spec.version = RSpec::Armour::VERSION
  spec.authors = ["Harry Lascelles"]
  spec.email = ["harry@harryl.com"]

  spec.summary = "Restrict mocking and stubbing of ActiveRecord models in RSpec."
  spec.description = <<~MSG
    rspec-armour prevents developers from mocking ActiveRecord finders, associations, and persistence methods, ensuring tests use real database interactions.
  MSG
  spec.homepage = "https://github.com/hlascelles/rspec-armour"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_dependency "rspec-mocks"
  spec.add_development_dependency "rubocop-magic_numbers"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "rubocop-thread_safety"
  spec.add_development_dependency "sqlite3"
end
