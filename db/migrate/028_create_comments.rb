class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
	    t.column :user_id,	:integer, :null => false
	    t.column :created_at, :datetime, :null => false
	    t.column :updated_at, :datetime, :null => false
	    t.column :updated_reason, :string
	    t.column :comment, :text, :null => false
	    t.column :deleted, :boolean, :null => false, :default => false
	    t.column :comment_collection_id, :integer, :null => false
    end

    add_index :comments, :user_id
    add_index :comments, :created_at
    add_index :comments, [:user_id, :created_at]

    execute "ALTER TABLE comments ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def self.down
    drop_table :comments
  end
end
