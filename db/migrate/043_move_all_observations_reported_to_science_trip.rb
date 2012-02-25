class MoveAllObservationsReportedToScienceTrip < ActiveRecord::Migration
  def self.up
	  remove_column :trips, 'all_observations_reported'
	  add_column :science_trips, 'all_observations_reported', :boolean, :null => false, :default => false
  end

  def self.down
  end
end
