# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "rspec-armor"
  spec.version = "0.1.0"
  spec.authors = ["Harry Lascelles"]
  spec.email = ["harry@harryl.com"]

  spec.summary = "American-spelling alias for rspec-armour. Please use rspec-armour instead."
  spec.description = <<~MSG
    This gem exists solely to prevent typo-squatting on the American spelling of rspec-armour.
    It installs rspec-armour (British spelling) and does nothing else.
    Please depend on rspec-armour directly.
  MSG
  spec.homepage = "https://github.com/hlascelles/rspec-armour"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = ["rspec-armor.gemspec"]

  spec.add_dependency "rspec-armour"
end
