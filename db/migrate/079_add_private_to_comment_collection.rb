class AddPrivateToCommentCollection < ActiveRecord::Migration
  def self.up
    add_column :comment_collections, :private, :boolean
  end

  def self.down
    remove_column :comment_collections, :private
  end
end
