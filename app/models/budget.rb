class Budget < ActiveRecord::Base
  belongs_to :family
  belongs_to :account
  validates_presence_of :family_id, :account_id, :year, :month
  validates_numericality_of :year, :month, :amount

  attr_accessible :family, :account, :year, :month, :amount
end
