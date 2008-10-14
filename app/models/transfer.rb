class Transfer < ActiveRecord::Base
  belongs_to :family
  belongs_to :debit_account, :class_name => "Account"
  belongs_to :credit_account, :class_name => "Account"
  validates_presence_of :family_id, :debit_account_id, :credit_account_id, :posted_on

  named_scope :for_period, lambda {|year, month| {:conditions => ["posted_on BETWEEN ? AND ?", Date.new(year, month, 1), Date.new(year, month, 1) + 1.month - 1.day]}}
  named_scope :credits, :conditions => {:debit_account_id => nil}
  named_scope :debits, :conditions => {:credit_account_id => nil}
  named_scope :for_account, lambda {|account| {:conditions => ["debit_account_id = :account_id OR credit_account_id = :account_id", {:account_id => account.id}]}}
end
