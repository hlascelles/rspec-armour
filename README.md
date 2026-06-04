# rspec-armour

`rspec-armour` protects your ActiveRecord models from being mocked or stubbed in RSpec tests. It forces you to use real database objects (or factories) for your models, leading to more robust and reliable tests.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-armour'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rspec-armour

## Usage

Once required, `rspec-armour` automatically prevents mocking of ActiveRecord finders, associations, and persistence methods.

### Examples of restricted methods:

*   **Class methods:** `.find`, `.where`, `.create`, `.update`, etc.
*   **Instance methods:** `#save`, `#update`, `#destroy`, `#reload`, etc.
*   **Associations:** `has_many`, `belongs_to`, and their helper methods (e.g., `user.items`, `user.item_ids`).

### Disabling restrictions

If you absolutely must mock an ActiveRecord method, you can do so by wrapping the code in a block:

```ruby
RSpec::Armour.without_restrictions do
  allow(User).to receive(:where).and_return([])
end
```

Or by using RSpec metadata:

```ruby
it "does something specific", :without_rspec_armour do
  allow(User).to receive(:where).and_return([])
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hlascelles/rspec-armour.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
