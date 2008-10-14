require File.dirname(__FILE__) + '/../test_helper'

class TransferTest < ActiveSupport::TestCase
  def test_scoped_to_credits
    transfer = Transfer.new(:credit_account => accounts(:home))
    transfer.save(false)
    assert_include transfer, Transfer.credits
  end

  def test_scoped_to_debits
    transfer = Transfer.new(:debit_account => accounts(:home))
    transfer.save(false)
    assert_include transfer, Transfer.debits
  end

  def test_debit_scope_does_not_include_credits
    transfer = Transfer.new(:credit_account => accounts(:home))
    transfer.save(false)
    assert_does_not_include transfer, Transfer.debits
  end

  def test_credit_scope_does_not_include_debits
    transfer = Transfer.new(:debit_account => accounts(:home))
    transfer.save(false)
    assert_does_not_include transfer, Transfer.credits
  end

  def test_scoped_to_period
    transfer = Transfer.new(:posted_on => Date.new(2008, 10, 13))
    transfer.save(false)
    assert_include transfer, Transfer.for_period(2008, 10)
  end

  def test_period_scope_does_not_include_next_month
    transfer = Transfer.new(:posted_on => Date.new(2008, 11, 1))
    transfer.save(false)
    assert_does_not_include transfer, Transfer.for_period(2008, 10)
  end

  def test_period_scope_does_not_include_previous_month
    transfer = Transfer.new(:posted_on => Date.new(2008, 9, 30))
    transfer.save(false)
    assert_does_not_include transfer, Transfer.for_period(2008, 10)
  end

  def test_scoped_to_credit_account
    transfer = Transfer.new(:credit_account => accounts(:home))
    transfer.save(false)
    assert_include transfer, Transfer.for_account(accounts(:home))
  end

  def test_scoped_to_debit_account
    transfer = Transfer.new(:debit_account => accounts(:home))
    transfer.save(false)
    assert_include transfer, Transfer.for_account(accounts(:home))
  end

  def test_account_scope_does_not_include_other_account
    transfer = Transfer.new(:debit_account => accounts(:home))
    transfer.save(false)
    assert_does_not_include transfer, Transfer.for_account(accounts(:credit_card))
  end
end
