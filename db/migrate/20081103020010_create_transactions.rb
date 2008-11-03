class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions, :force => true do |t|
      t.integer :family_id
      t.integer :bank_account_id
      t.integer :debit_account_id
      t.integer :credit_account_id
      t.date :posted_on
      t.decimal :amount, :precision => 12, :scale => 2
      t.string :name
      t.string :memo
      t.string :fitid

      t.timestamps
    end

    add_index :transactions, %w(family_id posted_on), :name => "by_family_posted"
    add_index :transactions, %w(family_id fitid), :name => "by_family_fitid", :unique => true
  end

  def self.down
    drop_table :transactions
  end
end
