require "digest/sha1"
require "rails_generator/secret_key_generator"

class Family < ActiveRecord::Base
  has_many :people, :dependent => :destroy
  has_many :transfers, :dependent => :destroy
  has_many :accounts, :order => "name", :dependent => :destroy
  has_many :budgets, :order => "account_id, year, month", :dependent => :destroy
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

  protected
  def generate_salt
    pid = Process.pid
    time = Time.now.utc.to_i
    data = "this is the secret key used by the generator -- needs to be unique (#{pid}, #{time})"
    self.salt = Rails::SecretKeyGenerator.new(data).generate_secret
  end
end
