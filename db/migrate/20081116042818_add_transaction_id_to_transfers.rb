class AddTransactionIdToTransfers < ActiveRecord::Migration
  def self.up
    add_column :transfers, :transaction_id, :integer
  end

  def self.down
    remove_column :transfers, :transaction_id
  end
end
