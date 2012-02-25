class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
	    t.column :name,	:string, :null => false
	    t.column :description, :string, :null => false
	    t.column :url,	:string, :null => false
	    t.column :sort_order, :integer
	    t.column :created_at, :datetime, :null => false
    end

    add_index(:forums, :url)
    add_index(:forums, :sort_order)

    create_table :comment_collections_forums, :id => false do |t|
	    t.column :forum_id, :integer, :null => false
	    t.column :comment_collection_id, :integer, :null => false
    end

    execute "ALTER TABLE comment_collections_forums ADD CONSTRAINT FOREIGN KEY (forum_id) REFERENCES forums(id)"
    execute "ALTER TABLE comment_collections_forums ADD CONSTRAINT FOREIGN KEY (comment_collection_id) REFERENCES comment_collections(id)"
  end

  def self.down
    drop_table :forums
    drop_table :comment_collections_forums
  end
end
