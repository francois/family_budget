require File.dirname(__FILE__) + '/../test_helper'

class BankAccountTest < Test::Unit::TestCase
  should_have_valid_fixtures
  should_require_attributes :family_id
  should_protect_attributes :family_id, :account_id, :display_account_number, :salted_account_number
  should_allow_attributes :family, :account, :bank_number, :account_number
  should_belong_to :account, :family
  should_have_many :bank_transactions

  context "A new BankAccount" do
    setup do
      @bank_account = families(:beausoleil).bank_accounts.build(:account_number => "4510111122223456", :bank_number => "92109291")
    end

    context "on save" do
      setup do
        @bank_account.save!
      end

      should "be findable by the original account number" do
        assert_equal @bank_account, BankAccount.find_by_family_and_account_number(families(:beausoleil), "4510111122223456")
      end

      should_change "@bank_account.account_number", :to => nil
      should_change "@bank_account.salted_account_number", :to => /^[\da-f]{40}$/
      should_change "@bank_account.display_account_number", :to => "4***********3456"
    end
  end

  context "BankAccount#to_s" do
    context "on a bank account with associated account" do
      setup do
        @bank_account = bank_accounts(:checking)
      end

      should "return the account's name" do
        assert_equal @bank_account.account.name, @bank_account.to_s
      end
    end

    context "on a bank account without an associated account" do
      setup do
        @bank_account = bank_accounts(:checking)
        @bank_account.account = nil
      end

      should "return the bank account's display number" do
        assert_equal @bank_account.display_account_number, @bank_account.to_s
      end
    end
  end
end
