class RemoveOldProfilePic < ActiveRecord::Migration
  def self.up
    drop_table 'profile_pics'
  end

  def self.down
  end
end
