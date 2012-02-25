class AddFootnoteToSpecies < ActiveRecord::Migration
  def self.up
    add_column :species, :note, :text
    add_column :species, :code, :string
  end

  def self.down
    remove_column :species, :note
    remove_column :species, :code
  end
end
