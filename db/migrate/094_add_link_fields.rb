class AddLinkFields < ActiveRecord::Migration
  def self.up
	  add_column :sightings, 'link', :text
	  add_column :user_locations, 'link', :text
	  add_column :trips, 'link', :text
  end

  def self.down
	  remove_column :sightings, 'link'
	  remove_column :user_locations, 'link'
	  remove_column :trips, 'link'
  end
end
