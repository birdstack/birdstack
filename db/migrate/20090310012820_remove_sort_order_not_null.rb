class RemoveSortOrderNotNull < ActiveRecord::Migration
  def self.up
    change_column :species, :sort_order, :integer, :null => true
    change_column :genera, :sort_order, :integer, :null => true
    change_column :families, :sort_order, :integer, :null => true
    change_column :orders, :sort_order, :integer, :null => true
  end

  def self.down
  end
end
