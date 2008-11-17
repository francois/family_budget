require File.dirname(__FILE__) + '/../test_helper'

class BankTransactionTest < Test::Unit::TestCase
  should_have_valid_fixtures
  should_belong_to :family, :bank_account, :credit_account, :debit_account
  should_protect_attributes :family_id, :bank_account_id, :credit_account_id, :debit_account_id
  should_allow_attributes :family, :bank_account, :credit_account, :debit_account, :amount, :posted_on, :name, :memo, :fitid
  should_require_attributes :family_id, :bank_account_id, :posted_on, :name, :fitid
  should_only_allow_numeric_values_for :amount
  should_allow_values_for :amount, 0, -100, 100, -99.99, 99.99

  context "A bank transaction with assigned bank account" do
    setup do
      @bank_transaction = bank_transactions(:credit_card_payment)
    end

    should "return the bank account's account when asked for #account" do
      assert_equal bank_accounts(:checking).account, @bank_transaction.account
    end

    context "that's been used to make a transfer" do
      setup do
        @transfer = families(:beausoleil).transfers.create!(:bank_transaction => @bank_transaction, :debit_account => accounts(:credit_card))
      end

      should "NOT appear in bank_transactions#pending scope" do
        assert_does_not_include @bank_transaction, families(:beausoleil).bank_transactions.pending.all
      end
    end

    context "that hasn't been used to make a transfer" do
      should "be in the bank_transactions#pending scope only once" do
        assert_equal 1, families(:beausoleil).bank_transactions(true).pending.all.select {|bt| bt == @bank_transaction}.length
      end
    end
  end
end
