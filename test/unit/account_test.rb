require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  should_belong_to :family
  should_have_many :budgets
  should_validate_presence_of :name, :purpose, :family_id
  should_require_unique_attributes :name, :scoped_to => :family_id
  should_not_allow_mass_assignment_of :family_id, :budget_ids
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

  context "An inactive income account" do
    setup do
      @account = families(:beausoleil).accounts.create!(:name => "salary", :purpose => Account::Income)
    end

    should "NOT be in the most active income accounts list" do
      assert_does_not_include @account, families(:beausoleil).accounts.most_active_income_in_period("200811")
    end

    should "NOT be in the most active expense accounts list" do
      assert_does_not_include @account, families(:beausoleil).accounts.most_active_expense_in_period("200811")
    end

    context "activated in 2008-12" do
      setup do
        families(:beausoleil).transfers.create!(:debit_account => accounts(:checking), :credit_account => @account, :amount => 1000, :posted_on => Date.new(2008, 12, 13))
      end

      should "NOT be in the most active income accounts list for 2008-11" do
        assert_does_not_include @account, families(:beausoleil).accounts.most_active_income_in_period("200811")
      end

      should "NOT be in the most active expense accounts list for 2008-11" do
        assert_does_not_include @account, families(:beausoleil).accounts.most_active_expense_in_period("200811")
      end

      should "NOT be in the most active expense accounts list for 2008-12" do
        assert_does_not_include @account, families(:beausoleil).accounts.most_active_expense_in_period("200812")
      end

      should "be in the most active income accounts list for 2008-12" do
        assert_include @account, families(:beausoleil).accounts.most_active_income_in_period("2008-12")
      end
    end
  end

  context "An inactive expense account" do
    setup do
      @account = families(:beausoleil).accounts.create!(:name => "mortgage repayment", :purpose => Account::Expense)
    end

    should "NOT be in the most active income accounts list" do
      assert_does_not_include @account, families(:beausoleil).accounts.most_active_income_in_period("200811")
    end

    should "NOT be in the most active expense accounts list" do
      assert_does_not_include @account, families(:beausoleil).accounts.most_active_expense_in_period("200811")
    end

    context "activated in 2008-12" do
      setup do
        families(:beausoleil).transfers.create!(:debit_account => @account, :credit_account => accounts(:checking), :amount => 100, :posted_on => Date.new(2008, 12, 13))
      end

      should "NOT be in the most active income accounts list for 2008-11" do
        assert_does_not_include @account, families(:beausoleil).accounts.most_active_income_in_period("200811")
      end

      should "NOT be in the most active expense accounts list for 2008-11" do
        assert_does_not_include @account, families(:beausoleil).accounts.most_active_expense_in_period("200811")
      end

      should "NOT be in the most active income accounts list for 2008-12" do
        assert_does_not_include @account, families(:beausoleil).accounts.most_active_income_in_period("200812")
      end

      should "be in the most active expense accounts list for 2008-12" do
        assert_include @account, families(:beausoleil).accounts.most_active_expense_in_period("2008-12")
      end
    end
  end
end
