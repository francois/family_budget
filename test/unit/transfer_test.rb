require File.dirname(__FILE__) + '/../test_helper'

class TransferTest < ActiveSupport::TestCase
  should_have_valid_fixtures
  should_protect_attributes :family, :family_id, :debit_account_id, :credit_account_id, :bank_transaction_id, :created_at, :updated_at
  should_require_attributes :family_id, :debit_account_id, :posted_on
  should_allow_attributes :debit_account, :credit_account, :bank_transaction, :posted_on, :description, :amount

  context "A new, empty, transfer" do
    setup do
      @transfer = families(:beausoleil).transfers.build(:posted_on => Date.today, :description => "bla bla")
    end

    context "with a debit and credit account" do
      setup do
        @transfer.debit_account = accounts(:checking)
        @transfer.credit_account = accounts(:credit_card)
      end

      context "and a positive amount" do
        setup do
          @transfer.amount = "123.45"
        end

        context "on save" do
          setup do
            # Expect success, so bang this!
            @transfer.save!
          end

          should_not_change "@transfer.amount"
          should_not_change "@transfer.debit_account"
          should_not_change "@transfer.credit_account"
        end
      end

      context "and a negative amount" do
        setup do
          @transfer.amount = "-123.45"
        end

        context "on save" do
          setup do
            # Expect success, so bang this!
            @transfer.save!
          end

          should_change "@transfer.amount", :to => 123.45

          should "change \"@transfer.debit_account\" to accounts(:credit_card)" do
            assert_equal accounts(:credit_card), @transfer.debit_account
          end

          should "change \"@transfer.credit_account\" to accounts(:checking)" do
            assert_equal accounts(:checking), @transfer.credit_account
          end
        end
      end
    end

    context "with a bank transaction" do
      setup do
        @transfer.bank_transaction = bank_transactions(:credit_card_payment)
      end

      context "on save" do
        setup do
          # Expect failure, so don't bang
          @transfer.save
        end

        should "be missing a debit account" do
          assert_include "Debit account can't be blank", @transfer.errors.full_messages
        end

        should "NOT be missing a credit account" do
          assert_does_not_include "Credit account can't be blank", @transfer.errors.full_messages
        end
      end
    end

    context "with a bank transaction reducing an asset bank account" do
      setup do
        @bank_transaction = families(:beausoleil).bank_transactions.create!(:amount => "-99.87", :bank_account => bank_accounts(:checking), :name => "CELL PHONE PAYMENT", :fitid => "J123J", :posted_on => Date.today)
        @transfer.bank_transaction = @bank_transaction
      end

      context "with a debit account that is an expense" do
        setup do
          @transfer.debit_account = accounts(:cell_phone_service)
        end

        context "on save" do
          setup do
            @transfer.save!
          end

          should "set the bank account's account as the credit account" do
            assert_equal bank_accounts(:checking).account, @transfer.credit_account
          end

          should "leave the debit account as-is" do
            assert_equal accounts(:cell_phone_service), @transfer.debit_account
          end
        end
      end
    end

    context "with a bank transaction increasing an asset bank account" do
      setup do
        @bank_transaction = families(:beausoleil).bank_transactions.create!(:amount => "1876.99", :bank_account => bank_accounts(:checking), :name => "DIRECT DEPOSIT", :memo => "37SIGNALS", :fitid => "9911209", :posted_on => Date.today)
        @transfer.bank_transaction = @bank_transaction
      end

      context "with a debit account that is an income" do
        setup do
          @transfer.debit_account = accounts(:salary)
        end

        context "on save" do
          setup do
            @transfer.save!
          end

          should "set the bank account's account as the debit account" do
            assert_equal bank_accounts(:checking).account, @transfer.debit_account
          end

          should "set the income account as the credit account" do
            assert_equal accounts(:salary), @transfer.credit_account
          end
        end
      end
    end

    context "with a bank transaction reducing a liability bank account" do
      context "with a debit account that is an asset account" do
        should "set the bank account's account as the debit account"
        should "set the asset's account to the credit account"
      end
    end

    context "with a bank transaction increasing a liability bank account" do
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
