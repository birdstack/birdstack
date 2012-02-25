class AddPhotoRightsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :default_photo_license, :string, :null => false, :default => "all-rights-reserved"
  end

  def self.down
    remove_column :users, :default_photo_license
  end
end
