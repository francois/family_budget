require File.dirname(__FILE__) + '/../test_helper'

class BankAccountTest < Test::Unit::TestCase
  should_have_valid_fixtures
  should_require_attributes :family_id, :account_number
  should_protect_attributes :family_id, :account_id
  should_allow_attributes :family, :account, :bank_number, :account_number
  should_belong_to :account, :family
  should_have_many :transactions

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

      should "return the bank account's number" do
        assert_equal @bank_account.account_number, @bank_account.to_s
      end
    end
  end
end
