require "digest/sha1"
require "rails_generator/secret_key_generator"

class Family < ActiveRecord::Base
  has_many :people, :dependent => :destroy
  has_many :transfers, :dependent => :destroy
  has_many :accounts, :order => "name", :dependent => :destroy
  has_many :budgets, :order => "account_id, starting_on", :dependent => :destroy
  has_many :bank_accounts
  has_many :bank_transactions

  validates_presence_of :name
  validates_uniqueness_of :name

  before_create :generate_salt

  attr_accessible :name

  def encrypt(*args)
    raise ArgumentError, "No salt defined in the family -- can't encrypt!" if salt.blank?
    args.flatten!
    args.compact!
    args.unshift(salt)
    Digest::SHA1.hexdigest("--%s--" % args.join("--"))
  end

  def budget_for(year, month)
    returning({}) do |hash|
      self.budgets.for_period(year, month).each {|budget| hash[budget.account] = budget}
      budgeted_accounts = hash.keys
      budgetable_accounts = self.accounts.expenses + self.accounts.incomes
      budgetable_accounts.delete_if {|a| budgeted_accounts.include?(a)}
      budgetable_accounts.each {|account| hash[account] = self.budgets.build(:account => account, :year => year, :month => month, :amount => 0)}
    end.values
  end

  def income_amounts_in_dates(range)
    amounts_in_dates(transfers.in_credit_accounts(accounts.purposes(Account::Income)), range)
  end

  def expense_amounts_in_dates(range)
    amounts_in_dates(transfers.in_debit_accounts(accounts.purposes(Account::Expense)), range)
  end

  protected
  def generate_salt
    pid = Process.pid
    time = Time.now.utc.to_i
    data = "this is the secret key used by the generator -- needs to be unique (#{pid}, #{time})"
    self.salt = Rails::SecretKeyGenerator.new(data).generate_secret
  end

  def amounts_in_dates(root, range)
    starting_on, ending_on = range.first, range.last
    starting_on = starting_on.beginning_of_month.to_date
    ending_on   = (ending_on.beginning_of_month >> 1).to_date
    data = root.within_period(starting_on .. ending_on).group_amounts_by_period.inject({}) do |memo, transfer|
      memo[Date.parse(transfer.period)] = transfer.amount.to_f
      memo
    end
    date = starting_on
    while date < ending_on
      data[date] = 0 unless data.has_key?(date)
      date = date >> 1
    end
    data.sort
  end
end
