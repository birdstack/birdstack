class PrivateToBool < ActiveRecord::Migration
  def self.up
    change_column :sighting_photos, :private, :bool, :null => false, :default => true
  end

  def self.down
  end
end
