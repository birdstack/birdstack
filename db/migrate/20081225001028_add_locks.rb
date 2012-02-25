class AddLocks < ActiveRecord::Migration
  def self.up
    add_column 'sightings', 'lock_version', :integer, :default => 0
    add_column 'user_locations', 'lock_version', :integer, :default => 0
    add_column 'trips', 'lock_version', :integer, :default => 0
  end

  def self.down
    remove_column 'sightings', 'lock_version'
    remove_column 'user_locations', 'lock_version'
    remove_column 'trips', 'lock_version'
  end
end
