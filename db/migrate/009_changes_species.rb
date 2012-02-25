class ChangesSpecies < ActiveRecord::Migration
  def self.up
	  create_table :changes_species, :id => false do |t|
		  t.column :change_id,	:integer, :null => false
		  t.column :species_id,	:integer, :null => false
	  end

	  add_index(:changes_species, :change_id)
	  add_index(:changes_species, :species_id)

	  execute "ALTER TABLE changes_species ADD CONSTRAINT FOREIGN KEY (change_id) REFERENCES changes(id)"
	  execute "ALTER TABLE changes_species ADD CONSTRAINT FOREIGN KEY (species_id) REFERENCES species(id)"
  end

  def self.down
	  drop_table :changes_species
  end
end
