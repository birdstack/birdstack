class SightingPhotoDescriptionText < ActiveRecord::Migration
  def self.up
    change_column :sighting_photos, :description, :text
  end

  def self.down
  end
end
