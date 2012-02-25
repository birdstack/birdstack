class CreateFriendRelationships < ActiveRecord::Migration
  def self.up
    create_table :friend_relationships do |t|
      t.integer :user_id, :null => false
      t.integer :friend_id, :null => false

      t.timestamps
    end
    execute "ALTER TABLE friend_relationships ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE friend_relationships ADD CONSTRAINT FOREIGN KEY (friend_id) REFERENCES users(id)"
  end

  def self.down
    drop_table :friend_relationships
  end
end
