class Budget < ActiveRecord::Base
  belongs_to :family
  belongs_to :account
  validates_presence_of :family_id, :account_id, :year, :month
  validates_numericality_of :year, :month, :amount

  attr_accessible :family, :account, :year, :month, :amount

  named_scope :for_period, lambda {|year, month| {:conditions => {:year => year, :month => month}}}
  named_scope :for_account_year_month, lambda {|account, year, month| {:conditions => {:account_id => account.id, :year => year, :month => month}}}
end
