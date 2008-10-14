class Account < ActiveRecord::Base
  belongs_to :family
  validates_presence_of :name, :purpose, :family_id
  validates_uniqueness_of :name, :scope => :family_id

  Asset = "asset"
  Liability = "liability"
  Equity = "equity"
  Income = "income"
  Expense = "expense"
  ValidPurposes = [Asset, Liability, Equity, Income, Expense]
  before_validation {|a| a.purpose = a.purpose.downcase unless a.purpose.blank?}
  validates_inclusion_of :purpose, :in => ValidPurposes

  has_many :budgets, :order => "year, month"

  named_scope :assets, :conditions => {:purpose => Asset}
  named_scope :liabilities, :conditions => {:purpose => Liability}
  named_scope :equities, :conditions => {:purpose => Equity}
  named_scope :incomes, :conditions => {:purpose => Income}
  named_scope :expenses, :conditions => {:purpose => Expense}
  named_scope :by_type_and_name, :order => "purpose, name"

  def real_amount_in_period(year, month)
    debits = self.family.transfers.all_debits_by_account_year_month(self, year, month)
    credits = self.family.transfers.all_credits_by_account_year_month(self, year, month)

    debit_amount = debits.map(&:amount).compact.sum
    credit_amount = credits.map(&:amount).compact.sum

    case purpose
    when "asset", "expense"
      debit_amount - credit_amount
    when "liability", "equity", "income"
      credit_amount - debit_amount
    end
  end

  def budget_amount_in_period(year, month)
    self.budgets.for_account_year_month(self, year, month).amount
  end

  def to_s
    name
  end
end
