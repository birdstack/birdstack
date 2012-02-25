class AddCachingToTaxo < ActiveRecord::Migration
  def self.up
	  add_column :genera, :species_count, :integer
	  add_column :families, :genus_count, :integer
	  add_column :orders, :family_count, :integer
  end

  def self.down
	  remove_column :genera, :species_count
	  remove_column :families, :genus_count
	  remove_column :orders, :family_count
  end
end
