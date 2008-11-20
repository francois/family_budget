class AddSaltToFamilies < ActiveRecord::Migration
  def self.up
    add_column :families, :salt, :string
  end

  def self.down
    remove_column :families, :salt
  end
end
