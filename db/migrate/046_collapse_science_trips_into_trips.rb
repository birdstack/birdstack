# Because we have no real data at this point, I'm just going to drop all previous science trip info

class CollapseScienceTripsIntoTrips < ActiveRecord::Migration
	def self.up
		drop_table :science_trips

		add_column :trips, :start_time_hour,		:integer
		add_column :trips, :start_time_minute,		:integer
		add_column :trips, :protocol,			:string, :null => false, :default => 'casual'
		add_column :trips, :number_observers,		:integer
		add_column :trips, :duration_hours,		:integer
		add_column :trips, :duration_minutes,		:integer
		add_column :trips, :distance_traveled_mi,	:float
		add_column :trips, :distance_traveled_km,	:float
		add_column :trips, :area_covered_acres,		:float
		add_column :trips, :area_covered_sqmi,		:float
		add_column :trips, :area_covered_sqkm,		:float
		add_column :trips, :date_day,			:integer
		add_column :trips, :date_month,			:integer
		add_column :trips, :date_year,			:integer
		add_column :trips, :all_observations_reported,	:boolean, :null => false, :default => false
	end

	def self.down
		# There's no going back from here!
		throw ActiveRecord::IrreversibleMigration
	end
end
