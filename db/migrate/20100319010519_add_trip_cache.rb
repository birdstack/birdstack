class AddTripCache < ActiveRecord::Migration
  def self.up
    add_column :sighting_photos, :trip_id, :integer

    SightingPhoto.reset_column_information
    SightingPhoto.all.each do |sp|
      sp.fill_in_cached_values
      sp.save!
    end

    execute "ALTER TABLE sighting_photos ADD CONSTRAINT FOREIGN KEY (trip_id) REFERENCES trips(id)"
  end

  def self.down
    remove_column :sighting_photos, :trip_id
  end
end
