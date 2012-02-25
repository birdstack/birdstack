class CreateMessageReferences < ActiveRecord::Migration
  def self.up
    create_table :message_references do |t|
      t.boolean :read, :default => false
      t.integer :user_id, :message_id

      t.timestamps
    end

    execute "ALTER TABLE message_references ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE message_references ADD CONSTRAINT FOREIGN KEY (message_id) REFERENCES messages(id)"
  end

  def self.down
    drop_table :message_references
  end
end
