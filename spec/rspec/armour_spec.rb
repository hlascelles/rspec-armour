# frozen_string_literal: true

require "spec_helper"
require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
  end

  create_table :items do |t|
    t.string :name
    t.integer :user_id
  end
end

class User < ActiveRecord::Base
  has_many :items
end

class Item < ActiveRecord::Base
  belongs_to :user
end

RSpec.describe RSpec::Armour do
  let(:user) { User.create!(name: "Test User") }

  describe "restrictions" do
    context "with class methods" do
      it "restricts mocking .where" do
        expect do
          allow(User).to receive(:where)
        end.to raise_error(RSpec::Armour::MockError, /where/)
      end

      it "restricts mocking .create!" do
        expect do
          allow(User).to receive(:create!)
        end.to raise_error(RSpec::Armour::MockError, /create!/)
      end

      it "restricts mocking .update" do
        expect do
          allow(User).to receive(:update)
        end.to raise_error(RSpec::Armour::MockError, /update/)
      end
    end

    context "with instance methods" do
      it "restricts mocking #save" do
        expect do
          allow(user).to receive(:save)
        end.to raise_error(RSpec::Armour::MockError, /save/)
      end

      it "restricts mocking #update!" do
        expect do
          allow(user).to receive(:update!)
        end.to raise_error(RSpec::Armour::MockError, /update!/)
      end

      it "restricts mocking #destroy" do
        expect do
          allow(user).to receive(:destroy)
        end.to raise_error(RSpec::Armour::MockError, /destroy/)
      end

      it "restricts mocking #reload" do
        expect do
          allow(user).to receive(:reload)
        end.to raise_error(RSpec::Armour::MockError, /reload/)
      end
    end

    context "with associations" do
      it "restricts mocking has_many association" do
        expect do
          allow(user).to receive(:items)
        end.to raise_error(RSpec::Armour::MockError, /items/)
      end

      it "restricts mocking association assignment" do
        expect do
          allow(user).to receive(:items=)
        end.to raise_error(RSpec::Armour::MockError, /items=/)
      end

      it "restricts mocking association _ids" do
        expect do
          allow(user).to receive(:item_ids)
        end.to raise_error(RSpec::Armour::MockError, /item_ids/)
      end

      it "restricts mocking belongs_to association" do
        item = Item.create!(name: "Test Item", user: user)
        expect do
          allow(item).to receive(:user)
        end.to raise_error(RSpec::Armour::MockError, /user/)
      end
    end

    context "with verifying doubles" do
      it "restricts mocking on instance_double" do
        user_double = instance_double(User)
        expect do
          allow(user_double).to receive(:items)
        end.to raise_error(RSpec::Armour::MockError, /items/)
      end

      it "restricts mocking on instance_double for persistence" do
        user_double = instance_double(User)
        expect do
          allow(user_double).to receive(:save)
        end.to raise_error(RSpec::Armour::MockError, /save/)
      end
    end

    context "with class_double" do
      it "restricts mocking on class_double" do
        user_class_double = class_double(User)
        expect do
          allow(user_class_double).to receive(:update)
        end.to raise_error(RSpec::Armour::MockError, /update/)
      end
    end

    context "with object_double" do
      it "restricts mocking on object_double (class)" do
        user_class_double = object_double(User)
        expect do
          allow(user_class_double).to receive(:find)
        end.to raise_error(RSpec::Armour::MockError, /find/)
      end

      it "restricts mocking on object_double (instance)" do
        user_double = object_double(User.new)
        expect do
          allow(user_double).to receive(:save)
        end.to raise_error(RSpec::Armour::MockError, /save/)
      end
    end
  end

  describe "disabling restrictions" do
    it "allows mocking when using .without_restrictions" do
      described_class.without_restrictions do
        allow(User).to receive(:where).and_return([])
        expect(User.where(name: "foo")).to eq([])
      end
    end

    it "allows mocking when using metadata", :without_rspec_armour do
      allow(User).to receive(:where).and_return([])
      expect(User.where(name: "foo")).to eq([])
    end
  end
end
