class CreatePendingImports < ActiveRecord::Migration
  def self.up
    create_table :pending_imports do |t|
      t.integer :user_id, :null => false
      t.string :filename, :null => false
      t.text :description

      t.timestamps
    end

    execute "ALTER TABLE pending_imports ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def self.down
    drop_table :pending_imports
  end
end
