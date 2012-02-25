class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
	    t.column :name,		:string, :null => false
	    t.column :description,	:string
	    t.column :parent_id,	:integer
	    t.column :rgt,		:integer
	    t.column :lft,		:integer
	    t.column :science_trip_id,	:integer
	    t.column :all_observations_reported, :boolean, :default => false
	    t.column :user_id,		:integer, :null => false
    end

    add_index :trips, :user_id

    execute "ALTER TABLE trips ADD CONSTRAINT FOREIGN KEY (science_trip_id) REFERENCES science_trips(id)"
    execute "ALTER TABLE trips ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE science_trips ADD CONSTRAINT FOREIGN KEY (trip_id) REFERENCES trips(id)"
  end

  def self.down
    drop_table :trips
  end
end
