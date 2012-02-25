class AddCommentCollectionToUserLocation < ActiveRecord::Migration
  def self.up
    add_column :user_locations, :comment_collection_id, :int

    say_with_time 'Updating locations' do
	    UserLocation.reset_column_information
	    UserLocation.find(:all).each do |location|
		    location.save!
		    announce location.id.to_s + ':' + location.comment_collection.id.to_s
	    end
    end

    change_column :user_locations, :comment_collection_id, :int, :null => false
    execute "ALTER TABLE user_locations ADD CONSTRAINT FOREIGN KEY (comment_collection_id) REFERENCES comment_collections(id)"
  end

  def self.down
    remove_column :user_locations, :comment_collection_id
  end
end
