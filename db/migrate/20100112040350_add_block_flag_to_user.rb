class AddBlockFlagToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :blocked, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :blocked
  end
end
