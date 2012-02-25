class CreatePrimaryAdm1s < ActiveRecord::Migration
  def self.up
    create_table :primary_adm1s do |t|
	    t.column :cc,	:string, :null => false
	    t.column :adm1,	:string, :null => false
	    t.column :adm1_id,	:integer, :null => false
    end

    add_index :primary_adm1s, [:cc, :adm1], :unique => true

    execute "ALTER TABLE primary_adm1s ADD CONSTRAINT FOREIGN KEY (adm1_id) REFERENCES adm1s(id)"
  end

  def self.down
    drop_table :primary_adm1s
  end
end
