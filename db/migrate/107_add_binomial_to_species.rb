class AddBinomialToSpecies < ActiveRecord::Migration
  def self.up
    add_column :species, :binomial_name_search_version, :string
  end

  def self.down
    remove_column :species, :binomial_name_search_version
  end
end
