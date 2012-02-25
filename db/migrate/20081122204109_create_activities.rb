class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.text :description, :null => false
      t.integer :user_id, :null => false
      t.datetime :occurred_at, :null => false

      t.timestamps
    end
    execute "ALTER TABLE activities ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def self.down
    drop_table :activities
  end
end
