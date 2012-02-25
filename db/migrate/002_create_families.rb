class CreateFamilies < ActiveRecord::Migration
  def self.up
    create_table :families do |t|
	    t.column :sort_order,	:integer, :null => false
	    t.column :order_id,		:integer, :null => false
	    t.column :english_name, 	:string, :null => false
	    t.column :latin_name,	:string, :null => false
    end

    add_index(:families, :sort_order, :unique => true)

    execute "ALTER TABLE families ADD CONSTRAINT FOREIGN KEY (order_id) REFERENCES orders(id)"
  end

  def self.down
    drop_table :families
  end
end
