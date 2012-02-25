class AddPhotoSizeTotal < ActiveRecord::Migration
  def self.up
    add_column :users, :photo_size_total, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :users, :photo_size_total
  end
end
