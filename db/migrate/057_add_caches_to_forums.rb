class AddCachesToForums < ActiveRecord::Migration
  def self.up
    add_column :forums, :thread_count, :int
    add_column :forums, :post_count, :int
    add_column :forums, :posted_at, :datetime
    add_column :forums, :posted_by, :int
    add_column :forums, :last_post_id, :int

    execute "ALTER TABLE forums ADD CONSTRAINT FOREIGN KEY (posted_by) REFERENCES users(id)"
    execute "ALTER TABLE forums ADD CONSTRAINT FOREIGN KEY (last_post_id) REFERENCES comments(id)"
  end

  def self.down
    remove_column :forums, :last_post_id
    remove_column :forums, :posted_by
    remove_column :forums, :posted_at
    remove_column :forums, :post_count
    remove_column :forums, :thread_count
  end
end
