class AddNotifyPhotoCommentToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_photo_comment, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :notify_photo_comment
  end
end
