class AddLicenseToSightingPhotos < ActiveRecord::Migration
  def self.up
    add_column :sighting_photos, :license, :string, :null => false
    execute "UPDATE sighting_photos SET license = 'all-rights-reserved'"
  end

  def self.down
    remove_column :sighting_photos, :license
  end
end
