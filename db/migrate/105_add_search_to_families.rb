class AddSearchToFamilies < ActiveRecord::Migration
  def self.up
    add_column :families, :english_name_search_version, :string
  end

  def self.down
    remove_column :families, :english_name_search_version
  end
end
