class AddTypeToCommentCollection < ActiveRecord::Migration
  def self.up
    add_column :comment_collections, :type, :string
  end

  def self.down
    remove_column :comment_collections, :type
  end
end
