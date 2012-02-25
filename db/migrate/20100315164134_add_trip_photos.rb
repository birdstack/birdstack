class AddTripPhotos < ActiveRecord::Migration
  def self.up
    create_table :trip_photos do |t|
      t.column :photo_file_name, :string, :null => false
      t.column :photo_content_type, :string, :null => false
      t.column :photo_file_size, :string, :null => false
      t.column :photo_updated_at, :datetime, :null => false

      t.column :title, :string, :null => false
      t.column :description, :text

      t.column :trip_id, :integer, :null => false

      t.column :processing, :boolean, :null => false

      t.column :user_id, :integer, :null => false
      t.column :private, :integer, :null => false
      t.column :comment_collection_id, :integer, :null => false

      t.column :license, :string, :null => false

      t.column :trip_photo_activity_id, :integer
      t.column :lock_version, :integer, :default => 0

      t.timestamps
    end

    execute "ALTER TABLE trip_photos ADD CONSTRAINT FOREIGN KEY (trip_photo_activity_id) REFERENCES activities(id)"
    execute "ALTER TABLE trip_photos ADD CONSTRAINT FOREIGN KEY (trip_id) REFERENCES trips(id)"
    execute "ALTER TABLE trip_photos ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE trip_photos ADD CONSTRAINT FOREIGN KEY (comment_collection_id) REFERENCES comment_collections(id)"
  end

  def self.down
    drop_table :trip_photos
  end
end
