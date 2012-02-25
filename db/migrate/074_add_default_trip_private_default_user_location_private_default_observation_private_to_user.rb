class AddDefaultTripPrivateDefaultUserLocationPrivateDefaultObservationPrivateToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :default_trip_private, :boolean
    add_column :users, :default_user_location_private, :integer
    add_column :users, :default_observation_private, :boolean
  end

  def self.down
    remove_column :users, :default_observation_private
    remove_column :users, :default_user_location_private
    remove_column :users, :default_trip_private
  end
end
