class RenameTransactionIdToBankTransactionIdInTransfers < ActiveRecord::Migration
  def self.up
    rename_column :transfers, :transaction_id, :bank_transaction_id
  end

  def self.down
    rename_column :transfers, :bank_transaction_id, :transaction_id
  end
end
