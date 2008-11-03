class BankAccount < ActiveRecord::Base
  belongs_to :account
  belongs_to :family
  validates_presence_of :family_id, :account_id, :bank_number, :account_number
  attr_accessible :family, :account, :bank_number, :account_number
  has_many :transactions
end
