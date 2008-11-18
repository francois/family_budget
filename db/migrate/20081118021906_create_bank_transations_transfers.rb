class CreateBankTransationsTransfers < ActiveRecord::Migration
  def self.up
    create_table :bank_transactions_transfers, :id => false do |t|
      t.integer :bank_transaction_id, :transfer_id
    end

    add_index :bank_transactions_transfers, %w(bank_transaction_id transfer_id), :unique => true, :name => "by_bank_transaction_transfer"
    add_index :bank_transactions_transfers, %w(transfer_id bank_transaction_id), :unique => true, :name => "by_transfer_bank_transaction"
  end

  def self.down
    drop_table :bank_transactions_transfers
  end
end
