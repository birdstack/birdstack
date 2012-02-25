class FixPhotoBool < ActiveRecord::Migration
  def self.up
    change_column :trip_photos, :private, :bool, :null => false, :default => true
  end

  def self.down
  end
end
