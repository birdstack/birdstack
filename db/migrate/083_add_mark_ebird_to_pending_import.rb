class AddMarkEbirdToPendingImport < ActiveRecord::Migration
  def self.up
    add_column :pending_imports, :ebird_exclude, :boolean, :null => false, :default => false
    add_column :sightings, :ebird_exclude, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :pending_imports, :ebird_exclude
    remove_column :sightings, :ebird_exclude
  end
end
