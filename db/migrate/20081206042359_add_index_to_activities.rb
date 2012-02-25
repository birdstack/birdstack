class AddIndexToActivities < ActiveRecord::Migration
  def self.up
    add_index 'activities', 'occurred_at'
  end

  def self.down
    remove_index 'activities', 'occurred_at'
  end
end
