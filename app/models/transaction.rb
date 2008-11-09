class Transaction < ActiveRecord::Base
  belongs_to :family
  belongs_to :bank_account
  belongs_to :debit_account, :class_name => "Account"
  belongs_to :credit_account, :class_name => "Account"

  attr_accessible :family, :bank_account, :debit_account, :credit_account, :amount, :name, :memo, :posted_on

  validates_numericality_of :amount
  validates_presence_of :family_id, :bank_account_id, :posted_on, :name, :fitid
end