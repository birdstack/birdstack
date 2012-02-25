class AddPrivateToSighting < ActiveRecord::Migration
  def self.up
    add_column :sightings, :private, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :sightings, :private
  end
end
