class CreateGenera < ActiveRecord::Migration
  def self.up
    create_table :genera do |t|
	    t.column :sort_order,	:integer, :null => false
	    t.column :family_id,	:integer, :null => false
            t.column :latin_name,	:string, :null => false
    end

    add_index(:genera, :sort_order, :unique => true)

    execute "ALTER TABLE genera ADD CONSTRAINT FOREIGN KEY (family_id) REFERENCES families(id)"
  end

  def self.down
    drop_table :genera
  end
end

