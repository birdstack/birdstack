class AddStiToCommentCollections < ActiveRecord::Migration
  def self.up
	  execute "UPDATE comment_collections SET type = 'SightingCommentCollection' WHERE id IN (SELECT comment_collection_id FROM sightings)"
	  execute "UPDATE comment_collections SET type = 'UserCommentCollection' WHERE id IN (SELECT comment_collection_id FROM users)"
	  execute "UPDATE comment_collections SET type = 'TripCommentCollection' WHERE id IN (SELECT comment_collection_id FROM trips)"
	  execute "UPDATE comment_collections SET type = 'ForumCommentCollection' WHERE id IN (SELECT comment_collection_id FROM comment_collections_forums)"
	  execute "UPDATE comment_collections SET type = 'UserLocationCommentCollection' WHERE id IN (SELECT comment_collection_id FROM user_locations)"
  end

  def self.down
  end
end
