class ReorderTrips < ActiveRecord::Migration
  def self.up
	  User.find(:all).each do |user|
		  trip = user.trips.find(:first)
		  trip.save if trip
	  end
  end

  def self.down
  end
end
