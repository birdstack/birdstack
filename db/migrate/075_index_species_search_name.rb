class IndexSpeciesSearchName < ActiveRecord::Migration
  def self.up
	  add_index :species, :english_name_search_version
  end

  def self.down
  end
end
