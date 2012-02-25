class EnhanceTrips < ActiveRecord::Migration
  def self.up
	  add_column :trips, :created_at, :datetime, :null => false
	  add_column :trips, :updated_at, :datetime, :null => false
  end

  def self.down
  end
end
