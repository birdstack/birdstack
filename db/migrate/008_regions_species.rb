class RegionsSpecies < ActiveRecord::Migration
  def self.up
	  create_table :regions_species, :id => false do |t|
		  t.column :region_id,	:integer, :null => false
		  t.column :species_id,	:integer, :null => false
	  end

	  add_index(:regions_species, :region_id)
	  add_index(:regions_species, :species_id)

	  execute "ALTER TABLE regions_species ADD CONSTRAINT FOREIGN KEY (region_id) REFERENCES regions(id)"
	  execute "ALTER TABLE regions_species ADD CONSTRAINT FOREIGN KEY (species_id) REFERENCES species(id)"
  end

  def self.down
	  drop_table :regions_species
  end
end
