class RemoveOtherNotNull < ActiveRecord::Migration
  def self.up
	  change_column :users, :comment_collection_id, :int, :null => true
	  change_column :sightings, :comment_collection_id, :int, :null => true
	  change_column :trips, :comment_collection_id, :int, :null => true
	  change_column :user_locations, :comment_collection_id, :int, :null => true
  end

  def self.down
  end
end
