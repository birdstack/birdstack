class CreateConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t|
      t.string :subject, :null => false

      t.timestamps
    end

    create_table :conversations_users do |t|
	t.integer :user_id, :conversation_id, :null => false
    end

    remove_column :conversations_users, :id

    execute "ALTER TABLE conversations_users ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE conversations_users ADD CONSTRAINT FOREIGN KEY (conversation_id) REFERENCES conversations(id)"

  end

  def self.down
    drop_table :conversations_users
    drop_table :conversations
  end
end
