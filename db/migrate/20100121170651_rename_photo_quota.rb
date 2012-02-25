class RenamePhotoQuota < ActiveRecord::Migration
  def self.up
    rename_column :users, 'photo_size_total', 'num_photos'
  end

  def self.down
  end
end
