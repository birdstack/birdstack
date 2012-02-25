class CreateFriendRequests < ActiveRecord::Migration
  def self.up
    create_table :friend_requests do |t|
      t.integer :user_id, :null => false
      t.integer :potential_friend_id, :null => false
      t.text :message

      t.timestamps
    end
    execute "ALTER TABLE friend_requests ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE friend_requests ADD CONSTRAINT FOREIGN KEY (potential_friend_id) REFERENCES users(id)"
  end

  def self.down
    drop_table :friend_requests
  end
end
