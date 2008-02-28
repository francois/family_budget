class CreateTransfers < ActiveRecord::Migration
  def self.up
    create_table :transfers do |t|
      t.integer :family_id
      t.date :posted_on
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :transfers
  end
end
