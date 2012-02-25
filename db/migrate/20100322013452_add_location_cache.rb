class AddLocationCache < ActiveRecord::Migration
  def self.up
    add_column :sighting_photos, :user_location_id, :integer

    SightingPhoto.reset_column_information
    SightingPhoto.all.each do |sp|
      sp.fill_in_cached_values
      sp.save!
    end

    execute "ALTER TABLE sighting_photos ADD CONSTRAINT FOREIGN KEY (user_location_id) REFERENCES user_locations(id)"
  end

  def self.down
    remove_column :sighting_photos, :user_location_id
  end
end
