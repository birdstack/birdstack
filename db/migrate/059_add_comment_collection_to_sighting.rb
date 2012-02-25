class AddCommentCollectionToSighting < ActiveRecord::Migration
  def self.up
    add_column :sightings, :comment_collection_id, :int

    say_with_time 'Updating sightings' do
	    Sighting.reset_column_information
	    Sighting.find(:all).each do |sighting|
		    sighting.save!
		    announce sighting.id.to_s + ':' + sighting.comment_collection_id.to_s
	    end
    end

    change_column :sightings, :comment_collection_id, :int, :null => false
    execute "ALTER TABLE sightings ADD CONSTRAINT FOREIGN KEY (comment_collection_id) REFERENCES comment_collections(id)"
  end

  def self.down
    remove_column :sightings, :comment_collection_id
  end
end
