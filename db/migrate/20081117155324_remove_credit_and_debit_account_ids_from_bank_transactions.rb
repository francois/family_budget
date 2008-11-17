class RemoveCreditAndDebitAccountIdsFromBankTransactions < ActiveRecord::Migration
  def self.up
    remove_column :bank_transactions, :debit_account_id
    remove_column :bank_transactions, :credit_account_id
  end

  def self.down
    add_column :bank_transactions, :debit_account_id, :integer
    add_column :bank_transactions, :credit_account_id, :integer
  end
end
