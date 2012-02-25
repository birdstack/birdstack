class AddSpeciesToSightingPhoto < ActiveRecord::Migration
  def self.up
    add_column :sighting_photos, :species_id, :integer, :null => false
    SightingPhoto.reset_column_information
    SightingPhoto.all.each do |sp|
      sp.species = sp.sighting.species
      sp.save!
    end
  end

  def self.down
  end
end
