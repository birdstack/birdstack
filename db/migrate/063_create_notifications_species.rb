class CreateNotificationsSpecies < ActiveRecord::Migration
  def self.up
	  create_table :notifications_species, :id => false do |t|
		  t.column :notification_id,	:integer, :null => false
		  t.column :species_id,	:integer, :null => false
	  end

	  execute "ALTER TABLE notifications_species ADD CONSTRAINT FOREIGN KEY (notification_id) REFERENCES notifications(id)"
	  execute "ALTER TABLE notifications_species ADD CONSTRAINT FOREIGN KEY (species_id) REFERENCES species(id)"
  end

  def self.down
	  drop_table :notifications_species
  end
end
