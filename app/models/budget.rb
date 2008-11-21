class Budget < ActiveRecord::Base
  belongs_to :family
  belongs_to :account
  validates_presence_of :family_id, :account_id
  validates_numericality_of :amount
  validate :require_year_and_month

  attr_writer :year, :month
  attr_accessible :family, :account, :year, :month, :amount

  named_scope :for_period, lambda {|year, month| {:conditions => {:starting_on => Date.new(year, month, 1)}}}
  named_scope :for_account_year_month, lambda {|account, year, month| {:conditions => {:account_id => account.id, :starting_on => Date.new(year, month, 1)}}}

  before_save :update_starting_on

  def year
    @year ||= starting_on ? starting_on.year : nil
  end

  def month
    @month ||= starting_on ? starting_on.month : nil
  end

  protected
  def update_starting_on
    self.starting_on = Date.new(self.year, self.month, 1)
  end

  def require_year_and_month
    errors.add("year", "can't be blank") if self.year.nil?
    errors.add("month", "can't be blank") if self.month.nil?
  end
end
