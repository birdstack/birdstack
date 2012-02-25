class AddValidatedFlagToPendingImportItem < ActiveRecord::Migration
  def self.up
    add_column :pending_import_items, :validated, :boolean
  end

  def self.down
    remove_column :pending_import_items, :validated
  end
end
