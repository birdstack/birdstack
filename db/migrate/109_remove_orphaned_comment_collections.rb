class RemoveOrphanedCommentCollections < ActiveRecord::Migration
  def self.up
	  SightingCommentCollection.find(:all, :conditions => "sightings.id IS NULL", :joins => "LEFT JOIN sightings ON sightings.comment_collection_id = comment_collections.id").each do |cc|
		  cc.destroy
	  end
	  UserLocationCommentCollection.find(:all, :conditions => "user_locations.id IS NULL", :joins => "LEFT JOIN user_locations ON user_locations.comment_collection_id = comment_collections.id").each do |cc|
		  cc.destroy
	  end
	  TripCommentCollection.find(:all, :conditions => "trips.id IS NULL", :joins => "LEFT JOIN trips ON trips.comment_collection_id = comment_collections.id").each do |cc|
		  cc.destroy
	  end
	  CommentCollection.find(:all, :conditions => "type IS NULL").each do |cc|
		  cc.destroy
	  end

	  change_column :comment_collections, :user_id, :int, :null => false
	  change_column :comment_collections, :type, :string, :null => false
  end

  def self.down
  end
end
