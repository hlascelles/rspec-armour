# rspec-armour

`rspec-armour` is the RSpec ActiveRecord MockUp Restrictor. It protects your ActiveRecord models
from being mocked or stubbed in RSpec tests. It forces you to use real database objects (or
factories) for your models, leading to more robust and reliable tests.

## Rationale and example usage

Given this production code:

```ruby
class User < ApplicationRecord
  has_many :posts
end

class SomeService
  def self.find_posted_user(id)
    User.includes(:posts).where(id: id).first
  end
end
```

You may find that your AI will suggest mocking the `User` model in your RSpec tests.
But this will return an object that will not have the `posts` association loaded, and your tests
will not be exercising the real code path. Instead, you should use a real database setup in your
tests.

```ruby
# Wrong
user = double("User", id: 3, name: "Alice")
expect(User).to receive(:where).with(id: 1).and_return([user])

# Right
user = User.create(id: 1, name: "Alice")
```

Driving this home to an AI with prompts is a Sisyphean task. Make it just error instead! Once
`rspec-armour` is installed, the mocking code will raise an `RSpec::Armour::MockError` and your
AI (and fellow devs) will know to use real database objects instead.

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

## Inspiration

The idea for this gem came from a discussion about the gem [rspec-mockbidden](https://github.com/lovro-bikic/rspec-mockbidden).
Hat tip to [@lovro-bikic](https://github.com/lovro-bikic)!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
