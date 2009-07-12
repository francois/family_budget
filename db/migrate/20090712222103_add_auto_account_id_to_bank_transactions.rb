class AddAutoAccountIdToBankTransactions < ActiveRecord::Migration
  def self.up
    add_column :bank_transactions, :auto_account_id, :integer
  end

  def self.down
    remove_column :bank_transactions, :auto_account_id
  end
end
