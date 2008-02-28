class TransferMember < ActiveRecord::Base
  belongs_to :transfer
  validates_uniqueness_of :account_id, :scope => :transfer_id
  validates_presence_of :transfer_id, :account_id
  validates_numericality_of :debit_amount, :credit_amount, :integer => false
end
