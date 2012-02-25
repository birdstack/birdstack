class UniqueScienceTrips < ActiveRecord::Migration
  def self.up
	  add_index :science_trips, :trip_id, :unique => true, :name => 'unique_index_science_trips_on_trip_id'
  end

  def self.down
  end
end
