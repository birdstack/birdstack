class CreateAdm1s < ActiveRecord::Migration
  def self.up
    create_table :adm1s do |t|
	    t.column :cc,	:string, :null => false
	    t.column :adm1,	:string, :null => false
	    t.column :name,	:string, :null => false
    end

    add_index :adm1s, 'cc'
  end

  def self.down
    drop_table :adm1s
  end
end
