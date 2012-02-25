class AddSupportingMemberToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :supporting_member, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :supporting_member
  end
end
