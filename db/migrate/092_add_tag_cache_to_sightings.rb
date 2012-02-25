class AddTagCacheToSightings < ActiveRecord::Migration
  def self.up
	  add_column :sightings, :cached_tag_list, :text
  end

  def self.down
	  drop_column :sightings, :cached_tag_list
  end
end
