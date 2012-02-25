class RemoveNotNull < ActiveRecord::Migration
  def self.up
	  change_column :comment_collections, :user_id, :int, :null => true
  end

  def self.down
  end
end
