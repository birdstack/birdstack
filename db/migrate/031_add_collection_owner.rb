class AddCollectionOwner < ActiveRecord::Migration
  def self.up
	  add_column :comment_collections, :user_id, :integer

	  User.find(:all).each do |u|
		  u.comment_collection.user_id = u.id
		  u.comment_collection.save!
	  end

	  execute "ALTER TABLE comment_collections ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def self.down
	  remove_column :comment_collections, :user_id
  end
end
