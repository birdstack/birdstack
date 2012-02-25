class AddPublicToSavedSearches < ActiveRecord::Migration
  def self.up
    add_column :saved_searches, :public, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :saved_searches, :public
  end
end
