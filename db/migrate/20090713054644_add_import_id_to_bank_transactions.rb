class AddImportIdToBankTransactions < ActiveRecord::Migration
  def self.up
    add_column :bank_transactions, :import_id, :integer
  end

  def self.down
    remove_column :bank_transactions, :import_id
  end
end
