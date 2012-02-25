class AddNotifyFriendRequestToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_friend_request, :boolean, :default => true, :null => false
    change_column :users, :notify_message, :boolean, :null => false, :default => true
    add_column :users, :pending_friend_requests, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :users, :notify_friend_request
    remove_column :users, :pending_friend_requests
  end
end
