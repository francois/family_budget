class DestroyTransferMember < ActiveRecord::Migration
  def self.up
    drop_table :transfer_members
  end

  def self.down
    create_table :transfer_members do |t|
      t.integer :transfer_id
      t.integer :account_id
      t.decimal :debit_amount, :credit_amount, :precision => 9, :scale => 2
    end
  end
end
