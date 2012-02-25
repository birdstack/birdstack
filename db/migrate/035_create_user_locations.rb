class CreateUserLocations < ActiveRecord::Migration
  def self.up
    create_table :user_locations do |t|
	    t.column :cc,	:string
	    t.column :adm1,	:string
	    t.column :adm2,	:string
	    t.column :location,	:string
	    t.column :name,	:string, :null => false
	    t.column :notes,	:text
	    t.column :latitude,	:decimal, :precision => 17, :scale => 15
	    t.column :longitude,:decimal, :precision => 18, :scale => 15
	    t.column :zoom,	:integer
	    t.column :source,	:string
	    t.column :user_id,	:integer, :null => false
	    t.column :created_at, :datetime, :null => false
	    t.column :updated_at, :datetime, :null => false
    end

    add_index :user_locations, :user_id

    execute "ALTER TABLE user_locations ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"

    add_index :user_locations, :name, :unique => true
  end

  def self.down
    drop_table :user_locations
  end
end
