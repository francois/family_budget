require File.dirname(__FILE__) + '/../test_helper'

class BankAccountTest < Test::Unit::TestCase
  should_require_attributes :family_id
  should_not_allow_mass_assignment_of :family_id, :account_id, :display_account_number, :salted_account_number
  should_allow_mass_assignment_of :family, :account, :bank_number, :account_number
  should_belong_to :account, :family
  should_have_many :bank_transactions

  context "An existing BankAccount" do
    setup do
      @bank_account = bank_accounts(:checking)
    end

    context "with a transfer attached to one of it's transactions" do
      setup do
        @transfer = families(:beausoleil).transfers.build(:debit_account => accounts(:cell_phone_service))
        @transfer.bank_transactions << bank_transactions(:credit_card_payment)
        @transfer.save!
      end

      context "on destroy" do
        setup do
          @bank_account.destroy
        end

        should_change "families(:beausoleil).bank_accounts.count", :by => -1
        should_change "families(:beausoleil).bank_transactions.count", :by => -1
        should_change "families(:beausoleil).transfers.count", :by => -2
      end
    end
  end

  context "A new BankAccount" do
    setup do
      @bank_account = families(:beausoleil).bank_accounts.build(:account_number => "4510111122223456", :bank_number => "92109291")
    end

    context "on save" do
      setup do
        @bank_account.save!
      end

      should "be findable by the original account number" do
        assert_equal @bank_account, BankAccount.find_by_family_and_bank_number_and_account_number(families(:beausoleil), "92109291", "4510111122223456")
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
