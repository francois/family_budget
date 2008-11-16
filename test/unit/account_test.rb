require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < ActiveSupport::TestCase
  should_have_valid_fixtures
  should_belong_to :family
  should_have_many :budgets
  should_require_attributes :name, :purpose, :family_id
  should_require_unique_attributes :name, :scoped_to => :family_id
  should_protect_attributes :family_id, :budget_ids
  should_not_allow_values_for :purpose, "foo", :message => "is not included in the list"
  should_allow_values_for :purpose, *Account::ValidPurposes

  context "An asset account" do
    setup do
      @account = Account.new(:purpose => Account::Asset)
    end

    should "return true for #asset?" do
      assert @account.asset?
    end

    should "return false for #liability?" do
      assert_equal false, @account.liability?
    end

    should "return false for #equity?" do
      assert_equal false, @account.equity?
    end

    should "return false for #income?" do
      assert_equal false, @account.income?
    end

    should "return false for #expense?" do
      assert_equal false, @account.expense?
    end
  end

  context "An expense account" do
    setup do
      @account = Account.new(:purpose => Account::Expense)
    end

    should "return false for #asset?" do
      assert_equal false, @account.asset?
    end

    should "return false for #liability?" do
      assert_equal false, @account.liability?
    end

    should "return false for #equity?" do
      assert_equal false, @account.equity?
    end

    should "return false for #income?" do
      assert_equal false, @account.income?
    end

    should "return true for #expense?" do
      assert @account.expense?
    end
  end
end
