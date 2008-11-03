class CreateBankAccounts < ActiveRecord::Migration
  def self.up
    create_table :bank_accounts, :force => true do |t|
      t.integer :family_id
      t.string :bank_number, :account_number
      t.integer :account_id

      t.timestamps
    end

    add_index :bank_accounts, %w(family_id bank_number account_number), :name => "by_family_bank_account", :unique => true
  end

  def self.down
    drop_table :bank_accounts
  end
end
