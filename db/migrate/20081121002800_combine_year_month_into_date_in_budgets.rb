class CombineYearMonthIntoDateInBudgets < ActiveRecord::Migration
  def self.up
    add_column :budgets, :starting_on, :date
    Budget.all.each do |budget|
      budget.starting_on = Date.new(budget.year, budget.month, 1)
      budget.save!
    end
    remove_column :budgets, :year
    remove_column :budgets, :month
  end

  def self.down
    add_column :budgets, :month, :integer
    add_column :budgets, :year, :integer
    Budget.all.each do |budget|
      budget.year = budget.starting_on.year
      budget.month = budget.starting_on.month
      budget.save!
    end
    remove_column :budgets, :starting_on
  end

  class Budget < ActiveRecord::Base; end
end
