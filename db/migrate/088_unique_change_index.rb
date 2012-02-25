class UniqueChangeIndex < ActiveRecord::Migration
  def self.up
	  add_index 'species', 'change_id', :unique => true
  end

  def self.down
  end
end
