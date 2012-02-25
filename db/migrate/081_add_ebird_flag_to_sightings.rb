class AddEbirdFlagToSightings < ActiveRecord::Migration
  def self.up
    add_column :sightings, :ebird, :integer
    add_index :sightings, :ebird
  end

  def self.down
    remove_column :sightings, :ebird
  end
end
