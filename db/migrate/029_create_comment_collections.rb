class CreateCommentCollections < ActiveRecord::Migration
  def self.up
    create_table :comment_collections do |t|
	    t.column :title, :string, :null => false
	    t.column :created_at, :datetime, :null => false
    end

    execute "ALTER TABLE comments ADD CONSTRAINT FOREIGN KEY (comment_collection_id) REFERENCES comment_collections(id)"
  end

  def self.down
    drop_table :comment_collections
  end
end
