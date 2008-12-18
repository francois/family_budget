class AddIgnoredAtToBankTransactions < ActiveRecord::Migration
  def self.up
    add_column :bank_transactions, :ignored_at, :datetime
  end

  def self.down
    remove_column :bank_transactions, :ignored_at
  end
end
