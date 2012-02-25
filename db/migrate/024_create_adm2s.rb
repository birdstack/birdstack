class CreateAdm2s < ActiveRecord::Migration
  def self.up
    create_table :adm2s do |t|
	    t.column :name,	:string, :null => false
	    t.column :cc,	:string, :null => false
	    t.column :adm1,	:string, :null => false
	    t.column :latitude,	:decimal, :precision => 9, :scale => 7, :null => false
	    t.column :longitude,:decimal, :precision => 10, :scale => 7, :null => false
    end

    add_index :adm2s, [:adm1, :cc]
  end

  def self.down
    drop_table :adm2s
  end
end
