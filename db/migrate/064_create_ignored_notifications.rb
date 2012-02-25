class CreateIgnoredNotifications < ActiveRecord::Migration
  def self.up
    create_table :ignored_notifications do |t|
      t.integer :user_id, :null => :false
      t.integer :notification_id, :null => :false

      t.timestamps
    end

    execute "ALTER TABLE ignored_notifications ADD CONSTRAINT FOREIGN KEY (notification_id) REFERENCES notifications(id)"
    execute "ALTER TABLE ignored_notifications ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def self.down
    drop_table :ignored_notifications
  end
end
