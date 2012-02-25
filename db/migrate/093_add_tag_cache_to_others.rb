class AddTagCacheToOthers < ActiveRecord::Migration
  def self.up
	  add_column :users, :cached_tag_list, :text
	  add_column :user_locations, :cached_tag_list, :text
	  add_column :trips, :cached_tag_list, :text
  end

  def self.down
	  drop_column :users, :cached_tag_list
	  drop_column :user_locations, :cached_tag_list
	  drop_column :trips, :cached_tag_list
  end
end
