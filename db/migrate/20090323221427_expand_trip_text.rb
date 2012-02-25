class ExpandTripText < ActiveRecord::Migration
  def self.up
    change_column :trips, :description, :text
  end

  def self.down
  end
end
