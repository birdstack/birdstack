class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
	    t.column :latitude,		:decimal, :precision => 9, :scale => 7, :null => false
	    t.column :longitude,	:decimal, :precision => 10, :scale => 7, :null => false
	    t.column :cc,		:string, :null => false
	    t.column :adm1,		:string, :null => false
	    t.column :adm2,		:string, :null => false
	    t.column :name, 		:string, :null => false
    end

    add_index :locations, :cc
  end

  def self.down
    drop_table :locations
  end
end
