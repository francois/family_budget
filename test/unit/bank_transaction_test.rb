require 'test_helper'

class BankTransactionTest < ActiveSupport::TestCase
  should_belong_to :family, :bank_account
  should_not_allow_mass_assignment_of :family_id, :bank_account_id, :ignored_at
  should_allow_mass_assignment_of :family, :bank_account, :amount, :posted_on, :name, :memo, :fitid, :bank_transactions
  should_validate_presence_of :family_id, :bank_account_id, :posted_on, :name, :fitid, :amount
  should_only_allow_numeric_values_for :amount
  should_allow_values_for :amount, 0, -100, 100, -99.99, 99.99
  should_require_unique_attributes :fitid, :scoped_to => :family_id

  context "A bank transaction with assigned bank account" do
    setup do
      @bank_transaction = bank_transactions(:credit_card_payment)
    end

    context "calling #ignore!" do
      setup do
        @bank_transaction.ignore!
      end

      context "calling #unignore!" do
        setup do
          @bank_transaction.unignore!
        end

        should_change "@bank_transaction.reload.ignored_at", :to => nil
        should_change "@bank_transaction.reload.ignored?", :to => false

        should "appear in the pending scope" do
          assert_contains BankTransaction.pending, @bank_transaction
        end
      end

      should_change "@bank_transaction.reload.ignored_at"
      should_change "@bank_transaction.reload.ignored?", :to => true

      should "NOT appear in the pending scope" do
        assert_does_not_contain BankTransaction.pending, @bank_transaction
      end
    end

    context "on the last day of October 2008" do
      setup do
        @bank_transaction.posted_on = Date.new(2008, 10, 31)
        @bank_transaction.save!
      end

      should "NOT appear for period 2008-11" do
        assert_does_not_contain families(:beausoleil).bank_transactions.in_period("200811"), @bank_transaction
      end

      should "appear for period 2008-10" do
        assert_contains families(:beausoleil).bank_transactions.in_period("200810"), @bank_transaction
      end
    end

    should "NOT appear when filtering by text and text isn't in name or memo" do
      assert_does_not_contain families(:beausoleil).bank_transactions.with_name_or_memo_like("POWER WALK"), @bank_transaction
    end

    should "appear when filtering by text and text in memo (case-insensitve search)" do
      assert_contains families(:beausoleil).bank_transactions.with_name_or_memo_like("TRANSFER W3"), @bank_transaction
    end

    should "appear when filtering by text and text in name (case-insensitve search)" do
      assert_contains families(:beausoleil).bank_transactions.with_name_or_memo_like("Payment"), @bank_transaction
    end

    should "appear when filtering by text and text in name" do
      assert_contains families(:beausoleil).bank_transactions.with_name_or_memo_like("PAYMENT"), @bank_transaction
    end

    should "appear when filtering by bank_account_id" do
      assert_contains families(:beausoleil).bank_transactions.on_bank_account(bank_transactions(:credit_card_payment).bank_account), @bank_transaction
    end

    should "NOT appear when filtering by another bank account" do
      assert_does_not_contain @bank_transaction, families(:beausoleil).bank_transactions.on_bank_account(bank_accounts(:credit_card))
    end

    should "NOT appear when filtering by posted_on for the previous year" do
      assert_does_not_contain @bank_transaction, families(:beausoleil).bank_transactions.in_period("2007")
    end

    should "NOT appear when filtering by posted_on for the next year" do
      assert_does_not_contain @bank_transaction, families(:beausoleil).bank_transactions.in_period("2009")
    end

    should "NOT appear when filtering by posted_on for the next period" do
      assert_does_not_contain @bank_transaction, families(:beausoleil).bank_transactions.in_period("200812")
    end

    should "NOT appear when filtering by posted_on for the previous period" do
      assert_does_not_contain @bank_transaction, families(:beausoleil).bank_transactions.in_period("2008-10")
    end

    should "appear when filtering by posted_on for the correct year/month" do
      assert_contains families(:beausoleil).bank_transactions.in_period("2008-11"), @bank_transaction
    end

    should "appear when filtering by posted_on for the correct year" do
      assert_contains families(:beausoleil).bank_transactions.in_period("2008"), @bank_transaction
    end

    should "return the bank account's account when asked for #account" do
      assert_equal bank_accounts(:checking).account, @bank_transaction.account
    end

    context "that's been used to make a transfer" do
      setup do
        @transfer = families(:beausoleil).transfers.create!(:credit_account => @bank_transaction.account, :debit_account => accounts(:credit_card), :posted_on => Date.today)
        @transfer.bank_transactions << @bank_transaction
      end
    
      should "NOT appear in bank_transactions#pending scope" do
        assert_does_not_contain @bank_transaction, families(:beausoleil).bank_transactions.pending.all
      end
    end
    
    context "that hasn't been used to make a transfer" do
      should "be in the bank_transactions#pending scope only once" do
        assert_equal 1, families(:beausoleil).bank_transactions(true).pending.all.select {|bt| bt == @bank_transaction}.length
      end
    end
  end
end
