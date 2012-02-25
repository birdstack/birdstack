class AddPrivateToUserLocationAndTrip < ActiveRecord::Migration
  def self.up
    add_column :user_locations, :private, :integer, :null => false, :default => 0
    add_column :trips, :private, :boolean, :null => false, :default => false

    add_index :sightings, :private
    add_index :user_locations, :private
    add_index :trips, :private
  end

  def self.down
    remove_column :user_locations, :private
    remove_column :trips, :private

    remove_index :sightings, :private
    remove_index :user_locations, :private
    remove_index :trips, :private
  end
end
