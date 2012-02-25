class RemoveUniqueIndexOnTripsNames < ActiveRecord::Migration
  def self.up
	  remove_index :trips, :name
	  add_index :trips, :name
  end

  def self.down
	  throw ActiveRecord::IrreversibleMigration
  end
end
