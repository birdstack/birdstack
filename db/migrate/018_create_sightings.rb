class CreateSightings < ActiveRecord::Migration
  def self.up
    create_table :sightings do |t|
	    t.column :user_id,		:integer, :null => false
	    t.column :species_id,	:integer, :null => false
	    t.column :created_at,	:datetime, :null => false
	    t.column :updated_at,	:datetime, :null => false
    end

    execute "ALTER TABLE sightings ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE sightings ADD CONSTRAINT FOREIGN KEY (species_id) REFERENCES species(id)"
  end

  def self.down
    drop_table :sightings
  end
end
