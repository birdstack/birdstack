class UniqueTripName < ActiveRecord::Migration
  def self.up
	  add_index :trips, :name, :unique => true
  end

  def self.down
  end
end
