class RemoveBankTransactionIdFromTransfers < ActiveRecord::Migration
  def self.up
    remove_column :transfers, :bank_transaction_id
  end

  def self.down
    add_column :transfers, :bank_transaction_id, :integer
  end
end
