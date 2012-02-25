class AddProfilePicToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :profile_pic_file_name,    :string
    add_column :users, :profile_pic_file_size,    :integer
    add_column :users, :profile_pic_updated_at,   :datetime
    add_column :users, :profile_pic_content_type, :string
  end

  def self.down
    remove_column :users, :profile_pic_file_name
    remove_column :users, :profile_pic_file_size
    remove_column :users, :profile_pic_updated_at
    remove_column :users, :profile_pic_content_type
  end
end
