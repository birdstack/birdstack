class CreateSavedSearches < ActiveRecord::Migration
  def self.up
	  create_table :saved_searches do |t|
		  t.string	:name, :null => false
		  t.text	:search, :null => false
		  t.timestamps
		  t.integer	:user_id, :null => false
	  end

	  execute "ALTER TABLE trips ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def self.down
	  drop_table :saved_searches
  end
end
