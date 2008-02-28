class CreateBudgets < ActiveRecord::Migration
  def self.up
    create_table :budgets do |t|
      t.integer :family_id
      t.integer :account_id
      t.integer :year
      t.integer :month
      t.decimal :amount, :precision => 9, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :budgets
  end
end
