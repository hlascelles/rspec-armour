# rspec-armour

`rspec-armour` is the RSpec ActiveRecord MockUp Restrictor. It protects your ActiveRecord models
from being mocked or stubbed in RSpec tests. It forces you to use real database objects (or
factories) for your models, leading to more robust and reliable tests.

## Installation

Add `rspec-armour` to the **test group** in your application's `Gemfile`:

```ruby
group :test do
  gem 'rspec-armour'
end
```

Then run:

    $ bundle install

Or install it yourself as:

    $ gem install rspec-armour

## Usage

Once required, `rspec-armour` automatically prevents mocking of ActiveRecord finders, associations, and persistence methods.

### Examples of restricted methods

| Category                 | Methods                                                                                                        |
|--------------------------|----------------------------------------------------------------------------------------------------------------|
| **Class finders**        | `.find`, `.find_by`, `.find_by!`, `.where`, `.all`, `.first`, `.last`, `.count`, `.pluck`, `.pick`, `.exists?` |
| **Class persistence**    | `.create`, `.create!`, `.update`, `.update!`, `.destroy_all`, `.delete_all`, `.delete_by`, `.destroy_by`       |
| **Instance persistence** | `#save`, `#save!`, `#update`, `#update!`, `#destroy`, `#destroy!`, `#delete`, `#touch`, `#reload`              |
| **Associations**         | `has_many`/`belongs_to` reader, writer, and `_ids` helpers (e.g. `user.posts`, `user.posts=`, `user.post_ids`) |

### What it looks like in practice

```ruby
# BAD — rspec-armour raises RSpec::Armour::MockError for these:
allow(User).to receive(:find).and_return(user)          # class finder
allow(User).to receive(:where).and_return([user])       # class finder
allow(user).to receive(:save).and_return(true)          # instance persistence
allow(user).to receive(:posts).and_return([post])       # association reader

# GOOD — use real database objects instead:
user = create(:user)          # FactoryBot / fixtures
post = create(:post, user:)   # real association in the DB
result = User.where(active: true)  # real query against test DB
```

### Disabling restrictions

If you absolutely must mock an ActiveRecord method, you can do so by wrapping the code in a block:

```ruby
RSpec::Armour.without_restrictions do
  allow(User).to receive(:where).and_return([])
end
```

Or by using RSpec metadata on an individual example or context:

```ruby
it "does something specific", :without_rspec_armour do
  allow(User).to receive(:where).and_return([])
end

context "legacy adapter", :without_rspec_armour do
  it "stubs the finder" do
    allow(User).to receive(:find).and_return(double)
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hlascelles/rspec-armour.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
