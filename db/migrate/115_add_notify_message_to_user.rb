class AddNotifyMessageToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_message, :boolean, :default => true
  end

  def self.down
    remove_column :users, :notify_message
  end
end
