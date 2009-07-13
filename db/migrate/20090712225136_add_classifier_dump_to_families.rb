class AddClassifierDumpToFamilies < ActiveRecord::Migration
  def self.up
    add_column :families, :classifier_dump, :text
  end

  def self.down
    remove_column :families, :classifier_dump
  end
end
