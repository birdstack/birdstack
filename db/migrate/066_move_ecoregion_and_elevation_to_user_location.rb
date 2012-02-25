class MoveEcoregionAndElevationToUserLocation < ActiveRecord::Migration
	def self.up
		remove_column :sightings, :ecoregion
		remove_column :sightings, :elevation_ft
		remove_column :sightings, :elevation_m

		add_column :user_locations, :ecoregion, :string
		add_column :user_locations, :elevation_ft, :float
		add_column :user_locations, :elevation_m, :float
	end

	def self.down
		throw ActiveRecord::IrreversibleMigration
	end
end
