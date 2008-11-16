class RenameTransactionsToBankTransactions < ActiveRecord::Migration
  def self.up
    rename_table :transactions, :bank_transactions
  end

  def self.down
    rename_table :bank_transactions, :transactions
  end
end
