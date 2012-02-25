class AddTempToSavedSearch < ActiveRecord::Migration
  def self.up
    add_column :saved_searches, :temp, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :saved_searches, :temp
  end
end
