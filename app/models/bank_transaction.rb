class BankTransaction < ActiveRecord::Base
  belongs_to :family
  belongs_to :bank_account
  delegate :account, :to => :bank_account
  belongs_to :transfer

  attr_accessible :family, :bank_account, :debit_account, :credit_account, :fitid, :amount, :name, :memo, :posted_on, :bank_transactions

  validates_numericality_of :amount
  validates_presence_of :family_id, :bank_account_id, :posted_on, :name, :fitid, :amount
  validates_uniqueness_of :fitid, :scope => :family_id

  named_scope :by_posted_on, :order => "posted_on"
  named_scope :pending, :conditions => "transfer_id IS NULL"
end
