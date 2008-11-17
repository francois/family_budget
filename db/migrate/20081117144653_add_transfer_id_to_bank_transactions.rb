class AddTransferIdToBankTransactions < ActiveRecord::Migration
  def self.up
    add_column :bank_transactions, :transfer_id, :integer
  end

  def self.down
    remove_column :bank_transactions, :transfer_id
  end
end
