class ChangeType < ActiveRecord::Migration
  def self.up
	  rename_column 'changes', 'type', 'change_type'
  end

  def self.down
	  rename_column 'changes', 'change_type', 'type'
  end
end
