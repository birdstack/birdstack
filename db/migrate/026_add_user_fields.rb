class AddUserFields < ActiveRecord::Migration
  def self.up
	  add_column :users, :gender, :string
	  add_column :users, :location, :string
	  add_column :users, :website, :text
	  add_column :users, :bio, :text
  end

  def self.down
	  remove_column :users, :gender
	  remove_column :users, :location
	  remove_column :users, :website
	  remove_column :users, :bio
  end
end
