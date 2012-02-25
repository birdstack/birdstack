class AddLocationPhotos < ActiveRecord::Migration
  def self.up
    create_table :user_location_photos do |t|
      t.column :photo_file_name, :string, :null => false
      t.column :photo_content_type, :string, :null => false
      t.column :photo_file_size, :string, :null => false
      t.column :photo_updated_at, :datetime, :null => false

      t.column :title, :string, :null => false
      t.column :description, :text

      t.column :user_location_id, :integer, :null => false

      t.column :processing, :boolean, :null => false

      t.column :user_id, :integer, :null => false
      t.column :private, :bool, :null => false
      t.column :comment_collection_id, :integer, :null => false

      t.column :license, :string, :null => false

      t.column :user_location_photo_activity_id, :integer
      t.column :lock_version, :integer, :default => 0

      t.timestamps
    end

    execute "ALTER TABLE user_location_photos ADD CONSTRAINT FOREIGN KEY (user_location_photo_activity_id) REFERENCES activities(id)"
    execute "ALTER TABLE user_location_photos ADD CONSTRAINT FOREIGN KEY (user_location_id) REFERENCES user_locations(id)"
    execute "ALTER TABLE user_location_photos ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE user_location_photos ADD CONSTRAINT FOREIGN KEY (comment_collection_id) REFERENCES comment_collections(id)"
  end

  def self.down
    drop_table :user_location_photos
  end
end
