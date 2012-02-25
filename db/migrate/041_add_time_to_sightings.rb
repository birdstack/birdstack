class AddTimeToSightings < ActiveRecord::Migration
  def self.up
	  add_column :sightings, :time_hour, :integer
	  add_column :sightings, :time_minute, :integer
  end

  def self.down
	  remove_column :sightings, :time_hour
	  remove_column :sightings, :time_minute
  end
end
