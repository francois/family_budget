class Account < ActiveRecord::Base
  belongs_to :family
  validates_presence_of :name, :purpose, :family_id

  Asset = "asset"
  Liability = "liability"
  Equity = "equity"
  Income = "income"
  Expense = "expense"
  ValidPurposes = [Asset, Liability, Equity, Income, Expense]
  before_validation {|a| a.purpose = a.purpose.downcase unless a.purpose.blank?}
  validates_inclusion_of :purpose, :in => ValidPurposes

  has_many :budgets, :order => "year, month"

  def to_s
    name
  end
end
