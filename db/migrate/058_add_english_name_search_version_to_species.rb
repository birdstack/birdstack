class AddEnglishNameSearchVersionToSpecies < ActiveRecord::Migration
  def self.up
    add_column :species, :english_name_search_version, :string
    Species.find(:all).each do |species|
	    species.save!
    end
    change_column :species, :english_name_search_version, :string, :null => false
  end

  def self.down
    remove_column :species, :english_name_search_version
  end
end
