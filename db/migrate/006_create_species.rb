class CreateSpecies < ActiveRecord::Migration
  def self.up
    create_table :species do |t|
	    t.column :sort_order,	:integer, :null => false
	    t.column :genus_id,		:integer, :null => false
	    t.column :english_name,	:string, :null => false
	    t.column :latin_name,	:string, :null => false
	    t.column :breeding_subregions, :string
	    t.column :nonbreeding_regions, :string
	    t.column :change_id,	:integer
    end

    add_index(:species, :sort_order, :unique => true)

    execute "ALTER TABLE species ADD CONSTRAINT FOREIGN KEY (genus_id) REFERENCES genera(id)"
    execute "ALTER TABLE species ADD CONSTRAINT FOREIGN KEY (change_id) REFERENCES changes(id)"
  end

  def self.down
    drop_table :species
  end
end
