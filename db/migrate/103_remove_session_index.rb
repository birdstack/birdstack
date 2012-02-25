class RemoveSessionIndex < ActiveRecord::Migration
  def self.up
	  remove_index :sessions, :updated_at
  end

  def self.down
  end
end
