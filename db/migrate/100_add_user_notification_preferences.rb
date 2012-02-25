class AddUserNotificationPreferences < ActiveRecord::Migration
  def self.up
	  add_column :users, :notify_profile_comment, :boolean, :default => true, :null => false
	  add_column :users, :notify_forum_comment, :boolean, :default => true, :null => false
	  add_column :users, :notify_sighting_comment, :boolean, :default => true, :null => false
	  add_column :users, :notify_user_location_comment, :boolean, :default => true, :null => false
	  add_column :users, :notify_trip_comment, :boolean, :default => true, :null => false
  end

  def self.down
	  remove_column :users, :notify_profile_comment
	  remove_column :users, :notify_forum_comment
	  remove_column :users, :notify_sighting_comment
	  remove_column :users, :notify_user_location_comment
	  remove_column :users, :notify_trip_comment
  end
end
