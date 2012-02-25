class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
	    t.column :code,	:string, :null => false
	    t.column :name,	:string, :null => false
	    t.column :description, :string
    end
  end

  def self.down
    drop_table :regions
  end
end
