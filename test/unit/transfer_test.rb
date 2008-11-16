require File.dirname(__FILE__) + '/../test_helper'

class TransferTest < ActiveSupport::TestCase
  should_have_valid_fixtures
  should_protect_attributes :family, :family_id, :debit_account_id, :credit_account_id, :bank_transaction_id, :created_at, :updated_at
  should_require_attributes :family_id, :posted_on
  should_allow_attributes :debit_account, :credit_account, :bank_transaction, :posted_on, :description, :amount

  context "A transfer" do
    setup do
      @transfer = families(:beausoleil).transfers.build
      @transfer.valid?
    end

    should "be missing a debit account" do
      assert_include "Debit account can't be blank", @transfer.errors.full_messages
    end

    should "be missing a credit account" do
      assert_include "Credit account can't be blank", @transfer.errors.full_messages
    end

    context "with a bank_transaction" do
      setup do
        @transfer.bank_transaction = bank_transactions(:credit_card_payment)
        @transfer.valid?
      end

      should "be missing a debit account" do
        assert_include "Debit account can't be blank", @transfer.errors.full_messages
      end

      should "NOT be missing a credit account" do
        assert_does_not_include "Credit account can't be blank", @transfer.errors.full_messages
      end
    end

    context "with a bank_transaction reducing an asset bank account" do
      context "with a debit account that is an expense" do
        should "set the bank account's account as the credit account"
        should "leave the debit account as-is"
      end
    end

    context "with a bank_transaction increasing an asset bank account" do
      context "with a debit account that is an income" do
        should "set the bank account's account as the debit account"
        should "set the income account as the credit account"
      end
    end

    context "with a bank_transaction reducing a liability bank account" do
      context "with a debit account that is an asset account" do
        should "set the bank account's account as the debit account"
        should "set the asset's account to the credit account"
      end
    end

    context "with a bank_transaction increasing a liability bank account" do
      context "with a debit account that is an expense" do
        should "set the bank account's account as the credit account"
        should "set the expense account as the debit account"
      end
    end
  end

  context "Scoping" do
    setup do
      @transfer = transfers(:checking_to_credit_card)
    end

    context "to period" do
      should "include the transfer when scoping to the right period" do
        assert_include @transfer, Transfer.for_period(2008, 11)
      end

      should "NOT include the transfer when scoping to the previous period" do
        assert_does_not_include @transfer, Transfer.for_period(2008, 10)
      end

      should "NOT include the transfer when scoping to the next period" do
        assert_does_not_include @transfer, Transfer.for_period(2008, 12)
      end

      should "NOT include the transfer when scoping to the right month but next year" do
        assert_does_not_include @transfer, Transfer.for_period(2009, 11)
      end

      should "NOT include the transfer when scoping to the right month but previous year" do
        assert_does_not_include @transfer, Transfer.for_period(2007, 11)
      end
    end

    context "to account" do
      should "include the transfer when the account is a debit" do
        assert_include @transfer, Transfer.for_account(accounts(:credit_card_repayment))
      end

      should "include the transfer when the account is a credit" do
        assert_include @transfer, Transfer.for_account(accounts(:checking))
      end

      should "include the transfer when the account isn't mentionned" do
        assert_does_not_include @transfer, Transfer.for_account(accounts(:credit_card))
      end
    end
  end
end
