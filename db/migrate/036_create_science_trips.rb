class CreateScienceTrips < ActiveRecord::Migration
  def self.up
    create_table :science_trips do |t|
	    t.column :start_time_hour,		:integer, :null => false
	    t.column :start_time_minute,	:integer, :null => false
	    t.column :protocol,			:string, :null => false
	    t.column :number_observers,		:integer
	    t.column :duration_hours,		:integer, :null => false
	    t.column :duration_minutes,		:integer, :null => false
	    t.column :distance_traveled_mi,	:float
	    t.column :distance_traveled_km,	:float
	    t.column :area_covered_acres,	:float
	    t.column :area_covered_sqmi,	:float
	    t.column :area_covered_sqkm,	:float
	    t.column :date_day,			:integer, :null => false
	    t.column :date_month,		:integer, :null => false
	    t.column :date_year,		:integer, :null => false
	    t.column :user_id,			:integer, :null => false
	    t.column :trip_id,			:integer, :null => false
    end

    add_index :science_trips, :trip_id
    add_index :science_trips, :user_id

    execute "ALTER TABLE science_trips ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def self.down
    drop_table :science_trips
  end
end
