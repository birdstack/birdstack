class LocationCcAdm1Index < ActiveRecord::Migration
  def self.up
	  add_index :locations, [:adm1, :cc]
  end

  def self.down
	  remove_index :locations, [:adm1, :cc]
  end
end
