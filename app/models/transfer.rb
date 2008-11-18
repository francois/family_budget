class Transfer < ActiveRecord::Base
  class MulitpleBankTransactionsNotHandledYet < RuntimeError; end

  belongs_to :family
  belongs_to :debit_account, :class_name => "Account"
  belongs_to :credit_account, :class_name => "Account"
  has_and_belongs_to_many :bank_transactions

  before_validation :copy_amount_from_bank_transactions
  before_validation :copy_posted_on_from_bank_transactions
  before_validation :normalize_accounts_with_bank_transactions
  after_validation :swap_accounts_on_negative_amount
  validates_presence_of :family_id, :posted_on, :debit_account_id, :credit_account_id
  validate :presence_of_bank_transactions_or_debit_and_credit_account
  validate :no_transfer_between_same_accounts

  attr_accessible :debit_account, :credit_account, :bank_transaction, :posted_on, :description, :amount

  named_scope :for_period, lambda {|year, month| {:conditions => ["posted_on BETWEEN ? AND ?", Date.new(year, month, 1), Date.new(year, month, 1) + 1.month - 1.day]}}
  named_scope :for_account, lambda {|account| {:conditions => ["debit_account_id = :account_id OR credit_account_id = :account_id", {:account_id => account.id}]}}

  protected
  def copy_amount_from_bank_transactions
    return if self.bank_transactions.empty?
    return unless self.amount.blank?
    self.amount = self.bank_transactions.map(&:amount).min
  end

  def copy_posted_on_from_bank_transactions
    return if self.bank_transactions.empty?
    self.posted_on = self.bank_transactions.map(&:posted_on).min
  end

  def swap_accounts_on_negative_amount
    return if self.amount.blank? || self.amount >= 0
    self.amount = self.amount.abs
    self.credit_account, self.debit_account = self.debit_account, self.credit_account
  end

  def normalize_accounts_with_bank_transactions
    return if [self.credit_account, self.debit_account].all?
    return if self.bank_transactions.empty?

    case self.bank_transactions.length
    when 1
      if self.amount < 0 then
        # Reducing the asset's value (withdrawing money from the account)
        self.credit_account = self.bank_transactions.first.account
        self.amount         = self.amount.abs
      else
        # Increasing the asset's value (depositing money into the account)
        self.debit_account, self.credit_account = self.bank_transactions.first.account, self.debit_account
      end
    when 2
      bt0 = self.bank_transactions.first
      bt1 = self.bank_transactions.last
      if bt0.amount < 0 then
        self.debit_account, self.credit_account = bt0.account, bt1.account
      else
        self.debit_account, self.credit_account = bt1.account, bt0.account
      end
    else
      raise MulitpleBankTransactionsNotHandledYet
    end
  end

  def presence_of_bank_transactions_or_debit_and_credit_account
    if self.bank_transactions.empty? then
      errors.add_on_blank("debit_account_id")
      errors.add_on_blank("credit_account_id")
    elsif self.bank_transactions.length == 1 then
      errors.add_on_blank("debit_account_id")
    elsif self.bank_transactions.length > 2 then
      errors.add_to_base("Cannot handle multiple bank transations at this time -- call François")
    end
  end

  def no_transfer_between_same_accounts
    return unless debit_account == credit_account
    errors.add("debit_account_id", "cannot be the same as the credit account")
    errors.add("credit_account_id", "cannot be the same as the debit account")
  end
end
