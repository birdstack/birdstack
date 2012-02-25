class AddCcToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :cc, :string
    
    add_index :users, :cc
    add_index :users, :location
  end

  def self.down
    remove_index :users, :cc
    remove_index :users, :location

    remove_column :users, :cc
  end
end
