class CreateSightingPhotos < ActiveRecord::Migration
  def self.up
    create_table :sighting_photos do |t|
      t.column :photo_file_name, :string, :null => false
      t.column :photo_content_type, :string, :null => false
      t.column :photo_file_size, :string, :null => false
      t.column :photo_updated_at, :datetime, :null => false

      t.column :title, :string, :null => false
      t.column :description, :string

      t.column :sighting_id, :integer, :null => false

      t.timestamps
    end

    execute "ALTER TABLE sighting_photos ADD CONSTRAINT FOREIGN KEY (sighting_id) REFERENCES sightings(id)"
  end

  def self.down
    drop_table :sighting_photos
  end
end
