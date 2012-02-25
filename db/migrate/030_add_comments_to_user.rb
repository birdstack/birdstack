class AddCommentsToUser < ActiveRecord::Migration
  def self.up
	  add_column :users, :comment_collection_id, :integer

	  User.find(:all).each do |u|
		  u.create_comment_collection(:title => u.login)
		  u.save!
	  end

	  change_column :users, :comment_collection_id, :integer, :null => false

	  execute "ALTER TABLE users ADD CONSTRAINT FOREIGN KEY (comment_collection_id) REFERENCES comment_collections(id)"
  end

  def self.down
	  remove_column :users, :comment_collection_id
  end
end
