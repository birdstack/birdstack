class AllowNullPrivate < ActiveRecord::Migration
  def self.up
	  change_column :sightings, :private, :boolean
	  change_column :trips, :private, :boolean
	  change_column :user_locations, :private, :integer
  end

  def self.down
  end
end
