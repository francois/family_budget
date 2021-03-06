class Account < ActiveRecord::Base
  belongs_to :family
  validates_presence_of :name, :purpose, :family_id
  validates_uniqueness_of :name, :scope => :family_id

  Asset         = "asset"
  Liability     = "liability"
  Equity        = "equity"
  Income        = "income"
  Expense       = "expense"
  ValidPurposes = [Asset, Liability, Equity, Income, Expense]
  before_validation {|a| a.purpose = a.purpose.downcase unless a.purpose.blank?}
  validates_inclusion_of :purpose, :in => ValidPurposes

  has_many :budgets, :order => "starting_on"

  named_scope :assets, :conditions => {:purpose => Asset}
  named_scope :liabilities, :conditions => {:purpose => Liability}
  named_scope :equities, :conditions => {:purpose => Equity}
  named_scope :incomes, :conditions => {:purpose => Income}
  named_scope :expenses, :conditions => {:purpose => Expense}
  named_scope :by_type_and_name, :order => "purpose, name"
  named_scope :purposes, lambda {|*purposes| {:conditions => {:purpose => purposes.flatten.compact}}}
  named_scope :by_most_debited, :select => "#{table_name}.*, SUM(#{Transfer.table_name}.amount) AS amount", :joins => "INNER JOIN #{Transfer.table_name} ON #{Transfer.table_name}.debit_account_id = #{table_name}.id", :order => "amount DESC", :group => "#{table_name}.family_id, #{table_name}.name, #{table_name}.purpose, #{table_name}.updated_at, #{table_name}.created_at, #{table_name}.id"
  named_scope :by_most_credited, :select => "#{table_name}.*, SUM(#{Transfer.table_name}.amount) AS amount", :joins => "INNER JOIN #{Transfer.table_name} ON #{Transfer.table_name}.credit_account_id = #{table_name}.id", :order => "amount DESC", :group => "#{table_name}.family_id, #{table_name}.name, #{table_name}.purpose, #{table_name}.updated_at, #{table_name}.created_at, #{table_name}.id"
  named_scope :in_period, lambda {|period|
    case period
    when /^(\d{4})-?(\d{2})/
      year, month = $1.to_i, $2.to_i
      start = Date.new(year, month, 1)
      {:conditions => ["#{Transfer.table_name}.posted_on BETWEEN ? AND ?", start, (start >> 1) - 1]}
    when /^(\d{4})/
      year = $1.to_i
      {:conditions => ["#{Transfer.table_name}.posted_on BETWEEN ? AND ?", Date.new(year, 1, 1), Date.new(year, 12, 31)]}
    when Date, Time, DateTime
      start = period.at_beginning_of_month.to_date
      {:conditions => ["#{Transfer.table_name}.posted_on BETWEEN ? AND ?", start, (start >> 1) - 1]}
    else
      {}
    end
  }

  attr_accessible :name, :purpose, :family

  def real_amount_in_period(year, month)
    debits  = self.family.transfers.in_debit_accounts(self).in_year_month(year, month)
    credits = self.family.transfers.in_credit_accounts(self).in_year_month(year, month)

    debit_amount  = debits.map(&:amount).compact.sum
    credit_amount = credits.map(&:amount).compact.sum

    normalize_amount(debit_amount, credit_amount)
  end

  def normalize_amount(debit_amount, credit_amount)
    case purpose
    when Asset, Expense
      debit_amount - credit_amount
    when Liability, Income, Equity
      credit_amount - debit_amount
    end

  end

  def budget_amount_in_period(year, month)
    self.budgets.for_account_year_month(self, year, month).map(&:amount).sum
  end

  def expense_or_income?
    expense? || income?
  end

  def to_s
    name
  end

  ValidPurposes.each do |purpose|
    class_eval <<-EOF
      def #{purpose}?
        purpose == #{purpose.titleize}
      end
    EOF
  end

  class << self
    def most_active_income_in_period(period, options={})
      in_period(period).purposes(Account::Income).by_most_credited.all(:order => "amount DESC")
    end

    def most_active_expense_in_period(period, options={})
      in_period(period).purposes(Account::Expense).by_most_debited.all(:order => "amount DESC")
    end
  end
end
