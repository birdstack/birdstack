class RemoveRedundantScienceTripIdFromTrips < ActiveRecord::Migration
  def self.up
	  execute 'ALTER TABLE trips DROP FOREIGN KEY trips_ibfk_1'
	  remove_column :trips, :science_trip_id
  end

  def self.down
  end
end
