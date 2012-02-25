class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :species_id, :null => false
      t.text :description, :null => false
      t.integer :user_id, :null => false

      t.timestamps
    end

    execute "ALTER TABLE notifications ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE notifications ADD CONSTRAINT FOREIGN KEY (species_id) REFERENCES species(id)"
  end

  def self.down
    drop_table :notifications
  end
end
