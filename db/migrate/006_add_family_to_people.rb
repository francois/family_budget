class AddFamilyToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :family_id, :integer
  end

  def self.down
    remove_column :people, :family_id
  end
end
