require File.dirname(__FILE__) + '/../test_helper'

class TransferTest < ActiveSupport::TestCase
  should_have_valid_fixtures
  should_protect_attributes :family_id, :debit_account_id, :credit_account_id, :created_at, :updated_at
  should_require_attributes :family_id, :debit_account_id, :credit_account_id, :posted_on
  should_allow_attributes :family, :debit_account, :credit_account, :posted_on, :description, :amount

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
        assert_include @transfer, Transfer.for_account(accounts(:home))
      end

      should "include the transfer when the account isn't mentionned" do
        assert_does_not_include @transfer, Transfer.for_account(accounts(:credit_card))
      end
    end
  end
end
