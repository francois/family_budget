class AddDebitAccountIdCreditAccountIdAndAmountToTransfers < ActiveRecord::Migration
  def self.up
    add_column :transfers, :debit_account_id, :integer
    add_column :transfers, :credit_account_id, :integer
    add_column :transfers, :amount, :decimal, :precision => 9, :scale => 2
  end

  def self.down
    remove_column :transfers, :amount
    remove_column :transfers, :credit_account_id
    remove_column :transfers, :debit_account_id
  end
end
