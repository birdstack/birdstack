class RenameActivity < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE sightings DROP FOREIGN KEY sightings_ibfk_7"
    rename_column :sightings, :activity_id, :sighting_activity_id
    execute "ALTER TABLE sightings ADD CONSTRAINT FOREIGN KEY (sighting_activity_id) REFERENCES activities(id)"
  end

  def self.down
    rename_column :sightings, :sighting_activity_id, :activity_id
  end
end
