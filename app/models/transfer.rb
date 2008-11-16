class Transfer < ActiveRecord::Base
  belongs_to :family
  belongs_to :debit_account, :class_name => "Account"
  belongs_to :credit_account, :class_name => "Account"
  belongs_to :bank_transaction
  validates_presence_of :family_id, :debit_account_id, :posted_on
  validate :presence_of_bank_transaction_or_credit_account

  attr_accessible :debit_account, :credit_account, :bank_transaction, :posted_on, :description, :amount

  named_scope :for_period, lambda {|year, month| {:conditions => ["posted_on BETWEEN ? AND ?", Date.new(year, month, 1), Date.new(year, month, 1) + 1.month - 1.day]}}
  named_scope :for_account, lambda {|account| {:conditions => ["debit_account_id = :account_id OR credit_account_id = :account_id", {:account_id => account.id}]}}

  def presence_of_bank_transaction_or_credit_account
    if self.bank_transaction.blank? then
      errors.add_on_blank("credit_account_id")
    else
      errors.add_on_blank("bank_transaction_id")
    end
  end
end
