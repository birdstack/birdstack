class AddCachesToCommentCollections < ActiveRecord::Migration
  def self.up
    add_column :comment_collections, :post_count, :int
    add_column :comment_collections, :posted_at, :datetime
    add_column :comment_collections, :posted_by, :int
    add_column :comment_collections, :last_post_id, :int

    execute "ALTER TABLE comment_collections ADD CONSTRAINT FOREIGN KEY (posted_by) REFERENCES users(id)"
    execute "ALTER TABLE comment_collections ADD CONSTRAINT FOREIGN KEY (last_post_id) REFERENCES comments(id)"
  end

  def self.down
    remove_column :comment_collections, :last_post_id
    remove_column :comment_collections, :posted_by
    remove_column :comment_collections, :posted_at
    remove_column :comment_collections, :post_count
  end
end
