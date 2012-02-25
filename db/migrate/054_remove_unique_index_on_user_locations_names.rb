class RemoveUniqueIndexOnUserLocationsNames < ActiveRecord::Migration
  def self.up
	  remove_index :user_locations, :name
	  add_index :user_locations, :name
  end

  def self.down
	  throw ActiveRecord::IrreversibleMigration
  end
end
