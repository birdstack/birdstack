class CommentCollectionIndices < ActiveRecord::Migration
  def self.up
	add_index :comment_collections_forums, :comment_collection_id, :unique => true
	add_index :sightings, :comment_collection_id, :unique => true
	add_index :trips, :comment_collection_id, :unique => true
	add_index :user_locations, :comment_collection_id, :unique => true
  end

  def self.down
	  throw ActiveRecord::IrreversibleMigration
  end
end
