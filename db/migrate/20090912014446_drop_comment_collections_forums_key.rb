class DropCommentCollectionsForumsKey < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE comment_collections_forums DROP KEY comment_collection_id"
    execute "ALTER TABLE comment_collections_forums ADD INDEX (comment_collection_id)"
    execute "ALTER TABLE comment_collections_forums DROP INDEX index_comment_collections_forums_on_comment_collection_id"
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
