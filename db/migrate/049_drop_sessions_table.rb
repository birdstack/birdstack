class DropSessionsTable < ActiveRecord::Migration
  def self.up
	drop_table :sessions
  end

  def self.down
	throw ActiveRecord::IrreversibleMigration
  end
end
