require File.dirname(__FILE__) + '/../test_helper'

class TransferTest < ActiveSupport::TestCase
  should_have_valid_fixtures
  should_protect_attributes :family, :family_id, :debit_account_id, :credit_account_id, :created_at, :updated_at
  should_require_attributes :family_id, :debit_account_id, :posted_on
  should_allow_attributes :debit_account, :credit_account, :posted_on, :description, :amount

  # It should be possible to split a single bank transaction into two or more transfers
  # A single withdrawal from a checking account could pay for two or more things:
  # gift for the lady of the house, and groceries at Wal Mart, for example.
  context "A bank transaction" do
    setup do
      @bank_transaction = families(:beausoleil).bank_transactions.create!(:amount => "-132.41", :bank_account => bank_accounts(:checking), :posted_on => Date.today, :name => "TOYS R US", :fitid => "9128391")
    end

    context "and two transfers against this transaction" do
      setup do
        @t0 = families(:beausoleil).transfers.build(:amount => -99.41, :debit_account => accounts(:gifts))
        @t0.bank_transactions << @bank_transaction
        @t0.save!
        @t1 = families(:beausoleil).transfers.build(:amount => -33, :debit_account => accounts(:movies))
        @t1.bank_transactions << @bank_transaction
        @t1.save!
      end

      should "set the amount to 99.41 for the gifts transfer" do
        assert_equal BigDecimal.new("99.41").to_s, @t0.amount.to_s
      end

      should "attach the transaction to the gifts transfer (simultaneously with the movies transfer)" do
        assert_include @bank_transaction, @t0.bank_transactions(true)
      end

      should "set the amount to 33 for the movies transfer" do
        assert_equal BigDecimal.new("33").to_s, @t1.amount.to_s
      end

      should "attach the transaction to the movies transfer (simultaneously with the gifts account)" do
        assert_include @bank_transaction, @t1.bank_transactions(true)
      end
    end
  end

  context "Two bank transactions withdrawing 250 from the checking account and depositing to credit card" do
    setup do
      @bt0 = create_bank_transaction(:bank_account => bank_accounts(:credit_card), :amount => "250")
      @bt1 = create_bank_transaction(:bank_account => bank_accounts(:checking), :amount => "-250", :posted_on => Date.today - 3)
    end

    context "used to repay said credit card" do
      setup do
        @transfer = families(:beausoleil).transfers.build
        @transfer.bank_transactions << @bt0
        @transfer.bank_transactions << @bt1
      end

      context "on save" do
        setup do
          @transfer.save!
        end

        should_change "@transfer.amount", :to => BigDecimal.new("250")
        should_change "@transfer.posted_on", :to => Date.today - 3

        should "debit the credit card account" do
          assert_equal accounts(:credit_card), @transfer.debit_account
        end

        should "credit the checking account" do
          assert_equal accounts(:checking), @transfer.credit_account
        end
      end
    end
  end

  context "Two bank transactions withdrawing 250 from the credit card account and depositing to the checking account" do
    setup do
      @bt0 = create_bank_transaction(:bank_account => bank_accounts(:checking), :amount => "250")
      @bt1 = create_bank_transaction(:bank_account => bank_accounts(:credit_card), :amount => "-250")
    end

    context "used to repay said credit card" do
      setup do
        @transfer = families(:beausoleil).transfers.build
        @transfer.bank_transactions << @bt0
        @transfer.bank_transactions << @bt1
      end

      context "on save" do
        setup do
          @transfer.save!
        end

        should_change "@transfer.amount", :to => BigDecimal.new("250")
        should_change "@transfer.posted_on", :to => Date.today

        should "credit the credit card account" do
          assert_equal accounts(:credit_card), @transfer.credit_account
        end

        should "debit the checking account" do
          assert_equal accounts(:checking), @transfer.debit_account
        end
      end
    end
  end

  context "A bank transaction of -58.98 to AT&T from my credit card" do
    setup do
      @bank_transaction = create_bank_transaction(:bank_account => bank_accounts(:credit_card), :amount => "-58.98")
    end

    context "used to pay for cell phone service" do
      setup do
        @transfer = families(:beausoleil).transfers.build(:debit_account => accounts(:cell_phone_service))
        @transfer.bank_transactions << @bank_transaction
      end

      context "on save" do
        setup do
          @transfer.save!
        end

        should_change "@transfer.amount", :to => BigDecimal.new("58.98")
        should_change "@transfer.posted_on", :to => Date.today

        should "the debit account to 'cell phone service'" do
          assert_equal accounts(:cell_phone_service), @transfer.debit_account
        end

        should "the credit account to 'credit card'" do
          assert_equal accounts(:credit_card), @transfer.credit_account
        end
      end
    end
  end

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
        @transfer.bank_transactions << bank_transactions(:credit_card_payment)
      end
    
      context "on save" do
        setup do
          # Expect failure, so don't bang
          @transfer.valid?
        end

        should "be invalid" do
          assert_invalid @transfer
        end
    
        should "be missing a debit account" do
          assert_include "Debit account can't be blank", @transfer.errors.full_messages
        end
    
        should "NOT be missing a credit account" do
          assert_does_not_include "Credit account can't be blank", @transfer.errors.full_messages
        end
      end
    end
  end

  context "A new, empty, transfer" do
    setup do
      @transfer = families(:beausoleil).transfers.build(:description => "bla bla")
    end
  
    context "with a bank transaction reducing an asset bank account" do
      setup do
        # Pay for cell phone service using checking account
        @bank_transaction = families(:beausoleil).bank_transactions.create!(:amount => "-99.87", :bank_account => bank_accounts(:checking), :name => "CELL PHONE PAYMENT", :fitid => "J123J", :posted_on => Date.new(2008, 11, 10))
        @transfer.bank_transactions << @bank_transaction
      end
  
      context "with a debit account that is an expense" do
        setup do
          @transfer.debit_account = accounts(:cell_phone_service)
        end
  
        context "on save" do
          setup do
            @transfer.save!
          end
  
          should_change "@transfer.amount", :to => 99.87
          should_change "@transfer.posted_on", :to => Date.new(2008, 11, 10)
  
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
        # Receive salary and deposit to checking account
        @bank_transaction = families(:beausoleil).bank_transactions.create!(:amount => "1876.99", :bank_account => bank_accounts(:checking), :name => "DIRECT DEPOSIT", :memo => "37SIGNALS", :fitid => "9911209", :posted_on => Date.new(2008, 11, 11))
        @transfer.bank_transactions << @bank_transaction
      end
  
      context "with a debit account that is an income" do
        setup do
          @transfer.debit_account = accounts(:salary)
        end
  
        context "on save" do
          setup do
            @transfer.save!
          end
  
          should_change "@transfer.amount", :to => 1876.99
          should_change "@transfer.posted_on", :to => Date.new(2008, 11, 11)
  
          should "set the bank account's account as the debit account" do
            assert_equal bank_accounts(:checking).account, @transfer.debit_account
          end
  
          should "set the income account as the credit account" do
            assert_equal accounts(:salary), @transfer.credit_account
          end
        end
      end
    end
  
    context "with a bank transaction increasing a liability bank account" do
      setup do
        @bank_transaction = families(:beausoleil).bank_transactions.create!(:amount => "-99.87", :bank_account => bank_accounts(:credit_card), :name => "CELL PHONE PAYMENT", :fitid => "J123J", :posted_on => Date.new(2008, 11, 13))
        @transfer.bank_transactions << @bank_transaction
      end
  
      context "with a debit account that is an expense account" do
        setup do
          # Pay for cell phone service using credit card
          @transfer.debit_account = accounts(:cell_phone_service)
        end
  
        context "on save" do
          setup do
            @transfer.save!
          end
  
          should_change "@transfer.amount", :to => 99.87
          should_change "@transfer.posted_on", :to => Date.new(2008, 11, 13)
  
          should "set the bank account's account as the credit account" do
            assert_equal bank_accounts(:credit_card).account, @transfer.credit_account
          end
  
          should "set the asset's account to the debit account" do
            assert_equal accounts(:cell_phone_service), @transfer.debit_account
          end
        end
      end
    end
  
    context "with a bank transaction decreasing a liability bank account" do
      setup do
        # Repay credit card using checking account
        @bank_transaction = families(:beausoleil).bank_transactions.create!(:amount => "250.00", :bank_account => bank_accounts(:credit_card), :name => "BANK TRANSFER", :fitid => "K2221", :posted_on => Date.new(2008, 11, 15))
        @transfer.bank_transactions << @bank_transaction
      end
  
      context "with a debit account that is an asset" do
        setup do
          @transfer.debit_account = accounts(:checking)
        end
  
        context "on save" do
          setup do
            @transfer.save!
          end
  
          should_change "@transfer.amount", :to => 250
          should_change "@transfer.posted_on", :to => Date.new(2008, 11, 15)
  
          should "set the bank account's account as the credit account" do
            assert_equal accounts(:checking), @transfer.credit_account
          end
  
          should "set the expense account as the debit account" do
            assert_equal accounts(:credit_card), @transfer.debit_account
          end
        end
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

  protected
  def hash_for_bank_transaction(attrs={})
    {:family => families(:beausoleil), :amount => "250", :fitid => "%d.%d" % [rand(100000), Time.now.utc.to_i], :name => "DEPOSIT", :posted_on => Date.today, :bank_account => bank_accounts(:checking)}.merge(attrs)
  end

  def create_bank_transaction(attrs={})
    BankTransaction.create!(hash_for_bank_transaction(attrs))
  end
end
