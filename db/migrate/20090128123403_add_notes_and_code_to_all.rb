class AddNotesAndCodeToAll < ActiveRecord::Migration
  def self.up
    add_column :orders, :code, :string
    add_column :orders, :note, :text

    add_column :families, :code, :string
    add_column :families, :note, :text

    add_column :genera, :code, :string
    add_column :genera, :note, :text
  end

  def self.down
  end
end
