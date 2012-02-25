class AddExportStartedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :export_started,   :datetime
  end

  def self.down
    remove_column :users, :export_started
  end
end
