class AddActivityIdToSightings < ActiveRecord::Migration
  def self.up
    add_column :sightings, :activity_id, :integer
    execute "ALTER TABLE sightings ADD CONSTRAINT FOREIGN KEY (activity_id) REFERENCES activities(id)"
  end

  def self.down
    remove_column :sightings, :activity_id
  end
end
