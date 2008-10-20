require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < ActiveSupport::TestCase
  should "have all valid fixtures" do
    Account.all.each do |account|
      assert account.valid?, "Fixture #{account.inspect} is invalid"
    end
  end

  should_belong_to :family
  should_have_many :budgets
  should_require_attributes :name, :purpose, :family_id
  should_require_unique_attributes :name, :scoped_to => :family_id
  should_protect_attributes :family_id, :budget_ids
  should_not_allow_values_for :purpose, "foo", :message => "is not included in the list"
  should_allow_values_for :purpose, *Account::ValidPurposes
end
