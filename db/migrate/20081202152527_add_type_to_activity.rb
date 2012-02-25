class AddTypeToActivity < ActiveRecord::Migration
  def self.up
    add_column  'activities', 'type', :string
    add_index   'activities', 'type'
    rename_column 'activities', 'description', 'data'
    change_column 'activities', 'data', :text
  end

  def self.down
    remove_column 'activities', 'type'
    rename_column 'activities', 'data', 'description'
  end
end
