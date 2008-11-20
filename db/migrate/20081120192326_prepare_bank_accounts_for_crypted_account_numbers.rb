class PrepareBankAccountsForCryptedAccountNumbers < ActiveRecord::Migration
  def self.up
    add_column :bank_accounts, :salted_account_number, :string
    rename_column :bank_accounts, :account_number, :display_account_number
    remove_index :bank_accounts, :name => :by_family_bank_account
    add_index :bank_accounts, :family_id, :name => :by_family
  end

  def self.down
    rename_column :bank_accounts, :display_account_number, :account_number
    remove_column :bank_accounts, :salted_account_number
    remove_index :bank_accounts, :name => :by_family
    add_index :bank_accounts, %w(family_id bank_number account_number), :unique => true, :name => :by_family_bank_account
  end
end
