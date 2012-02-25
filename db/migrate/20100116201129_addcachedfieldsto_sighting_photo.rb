class AddcachedfieldstoSightingPhoto < ActiveRecord::Migration
  def self.up
    add_column :sighting_photos, :user_id, :integer, :null => false
    add_column :sighting_photos, :private, :integer, :null => false
    add_column :sighting_photos, :comment_collection_id, :integer, :null => false

    SightingPhoto.all.each do |sp|
      sp.user = sp.sighting.user
      sp.private = sp.sighting.private
      sp.create_comment_collection
      sp.save!
    end

    execute "ALTER TABLE sighting_photos ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE sighting_photos ADD CONSTRAINT FOREIGN KEY (comment_collection_id) REFERENCES comment_collections(id)"
  end

  def self.down
  end
end
