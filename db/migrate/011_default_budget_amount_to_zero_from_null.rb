class DefaultBudgetAmountToZeroFromNull < ActiveRecord::Migration
  def self.up
    change_column :budgets, :amount, :decimal, :precision => 9, :scale => 2, :default => 0
  end

  def self.down
    change_column :budgets, :amount, :decimal, :precision => 9, :scale => 2
  end
end
