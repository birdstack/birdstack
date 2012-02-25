class MustSelectAllObserved < ActiveRecord::Migration
  def self.up
	  change_column :trips, :all_observations_reported, :boolean, :null => false, :default => false
  end

  def self.down
  end
end
