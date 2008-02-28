class Family < ActiveRecord::Base
  has_many :people
  has_many :transfers
  has_many :accounts, :order => "name", :extend => Extensions::Accounts
  has_many :budgets, :order => "account_id, year, month", :extend => Extensions::Budgets
end
