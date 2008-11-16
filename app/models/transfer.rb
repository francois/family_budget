class Transfer < ActiveRecord::Base
  belongs_to :family
  belongs_to :debit_account, :class_name => "Account"
  belongs_to :credit_account, :class_name => "Account"
  belongs_to :bank_transaction

  before_validation :copy_amount_from_bank_transaction
  before_validation :copy_posted_on_from_bank_transaction
  after_validation :normalize_accounts_on_transaction
  after_validation :swap_accounts_on_negative_amount
  validates_presence_of :family_id, :debit_account_id, :posted_on
  validate :presence_of_bank_transaction_or_credit_account

  attr_accessible :debit_account, :credit_account, :bank_transaction, :posted_on, :description, :amount

  named_scope :for_period, lambda {|year, month| {:conditions => ["posted_on BETWEEN ? AND ?", Date.new(year, month, 1), Date.new(year, month, 1) + 1.month - 1.day]}}
  named_scope :for_account, lambda {|account| {:conditions => ["debit_account_id = :account_id OR credit_account_id = :account_id", {:account_id => account.id}]}}

  protected
  def copy_amount_from_bank_transaction
    self.amount = self.bank_transaction.amount if self.amount.blank? && !self.bank_transaction.blank?
  end

  def copy_posted_on_from_bank_transaction
    self.posted_on = self.bank_transaction.posted_on if self.posted_on.blank? && !self.bank_transaction.blank?
  end

  def swap_accounts_on_negative_amount
    return if self.amount.blank? || self.amount >= 0
    self.amount = self.amount.abs
    self.credit_account, self.debit_account = self.debit_account, self.credit_account
  end

  def normalize_accounts_on_transaction
    return if [self.credit_account, self.debit_account].all?
    return if self.bank_transaction.blank?
    if self.amount < 0 then
      # Reducing the asset's value (withdrawing money from the account)
      self.credit_account = self.bank_transaction.account
      self.amount         = self.amount.abs
    else
      # Increasing the asset's value (depositing money into the account)
      self.debit_account, self.credit_account = self.bank_transaction.account, self.debit_account
    end
  end

  def presence_of_bank_transaction_or_credit_account
    if self.bank_transaction.blank? then
      errors.add_on_blank("credit_account_id")
    else
      errors.add_on_blank("bank_transaction_id")
    end
  end
end
