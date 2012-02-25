class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.text :body, :null => false
      t.integer :user_id, :conversation_id, :null => false

      t.timestamps
    end

    execute "ALTER TABLE messages ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE messages ADD CONSTRAINT FOREIGN KEY (conversation_id) REFERENCES conversations(id)"
  end

  def self.down
    drop_table :messages
  end
end
