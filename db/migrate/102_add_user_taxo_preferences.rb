class AddUserTaxoPreferences < ActiveRecord::Migration
  def self.up
	  add_column :users, :notify_taxonomy_changes, :boolean, :default => true, :null => false
  end

  def self.down
	  remove_column :users, :notify_taxonomy_changes
  end
end
