class AddProcessingToSightingPhoto < ActiveRecord::Migration
  def self.up
    add_column :sighting_photos, :processing, :boolean, :null => false
  end

  def self.down
    remove_column :sighting_photos, :processing
  end
end
