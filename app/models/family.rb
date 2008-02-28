class Family < ActiveRecord::Base
  has_many :people
  has_many :transfers
  has_many :accounts, :order => "name", :extend => Extensions::Accounts
  has_many :budgets, :order => "account_id, year, month", :extend => Extensions::Budgets

  def budget_for(year, month)
    returning({}) do |hash|
      self.budgets.for_period(year, month).each {|budget| hash[budget.account] = budget}
      budgeted_accounts = hash.keys
      budgetable_accounts = self.accounts.expenses + self.accounts.incomes
      budgetable_accounts.delete_if {|a| budgeted_accounts.include?(a)}
      budgetable_accounts.each {|account| hash[account] = self.budgets.build(:account => account, :year => year, :month => month, :amount => 0)}
    end.values
  end
end
