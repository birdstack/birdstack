class AddCommentCollectionToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips, :comment_collection_id, :int

    say_with_time 'Updating trips' do
	    Trip.reset_column_information
	    Trip.find(:all).each do |trip|
		    trip.save!
		    announce trip.id.to_s + ':' + trip.comment_collection.id.to_s
	    end
    end

    change_column :trips, :comment_collection_id, :int, :null => false
    execute "ALTER TABLE trips ADD CONSTRAINT FOREIGN KEY (comment_collection_id) REFERENCES comment_collections(id)"
  end

  def self.down
    remove_column :trips, :comment_collection_id
  end
end
