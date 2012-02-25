class AddActivityToSightingPhotos < ActiveRecord::Migration
  def self.up
    # rename sightings.activity to sighting_activity_id
    add_column :sighting_photos, :sighting_photo_activity_id, :integer
    execute "ALTER TABLE sighting_photos ADD CONSTRAINT FOREIGN KEY (sighting_photo_activity_id) REFERENCES activities(id)"
    add_column 'sighting_photos', 'lock_version', :integer, :default => 0
  end

  def self.down
    remove_column :sighting_photos, :activity_id
    remove_column :sighting_photos, :lock_version
  end
end
