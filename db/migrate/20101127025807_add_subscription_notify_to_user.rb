class AddSubscriptionNotifyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_membership, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :notify_membership
  end
end
