class AddAdminFlagToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :admin, :boolean
  end

  def self.down
    remove_column :people, :admin
  end
end
