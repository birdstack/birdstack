class CreateProfilePics < ActiveRecord::Migration
  def self.up
    create_table :profile_pics do |t|
	    t.column :user_id,		:integer, :null => false
	    t.column :picture,		:binary
	    t.column :picture_small,	:binary
	    t.column :updated_at,	:datetime, :null => false
    end

    # We only want one profile pic per user
    add_index(:profile_pics, 'user_id', :unique => true)

    execute "ALTER TABLE profile_pics ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def self.down
    drop_table :profile_pics
  end
end
