class RealSightings < ActiveRecord::Migration
  def self.up
    self.down

    create_table :sightings do |t|
	    t.column :user_id,		:integer, :null => false
	    t.column :species_id,	:integer, :null => false
	    t.column :created_at,	:datetime, :null => false
	    t.column :updated_at,	:datetime, :null => false
	    t.column :user_location_id,	:integer
	    t.column :date_day,		:integer
	    t.column :date_month,	:integer
	    t.column :date_year,	:integer
	    t.column :trip_id,		:integer
	    t.column :species_count,	:integer
	    t.column :juvenile_male,	:integer
	    t.column :juvenile_female,	:integer
	    t.column :juvenile_unknown,	:integer
	    t.column :immature_male,	:integer
	    t.column :immature_female,	:integer
	    t.column :immature_unknown,	:integer
	    t.column :adult_male,	:integer
	    t.column :adult_female,	:integer
	    t.column :adult_unknown,	:integer
	    t.column :unknown_male,	:integer
	    t.column :unknown_female,	:integer
	    t.column :unknown_unknown,	:integer
	    t.column :elevation_ft,	:float
	    t.column :elevation_m,	:float
	    t.column :ecoregion,	:string
	    t.column :notes,		:text
    end

    add_index :sightings, :user_id

    execute "ALTER TABLE sightings ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE sightings ADD CONSTRAINT FOREIGN KEY (species_id) REFERENCES species(id)"
    execute "ALTER TABLE sightings ADD CONSTRAINT FOREIGN KEY (user_location_id) REFERENCES user_locations(id)"
    execute "ALTER TABLE sightings ADD CONSTRAINT FOREIGN KEY (trip_id) REFERENCES trips(id)"
  end

  def self.down
    drop_table :sightings
  end
end
