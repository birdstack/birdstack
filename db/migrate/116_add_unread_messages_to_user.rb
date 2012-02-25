class AddUnreadMessagesToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :unread_messages, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :users, :unread_messages
  end
end
