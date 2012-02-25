class AddTimePrefsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :time_24_hr, :boolean, :null => false, :default => true
    add_column :users, :time_day_first, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :time_day_first
    remove_column :users, :time_24_hr
  end
end
