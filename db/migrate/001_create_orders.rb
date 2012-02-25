class CreateOrders < ActiveRecord::Migration
  def self.up
    # This is a retroactive change.  It should have been the very first migration, but I don't know how well that works
    # Setting up the correct character set and collation is extremely important tho, so I'll put it here

    execute("ALTER DATABASE CHARACTER SET utf8")
    execute("ALTER DATABASE COLLATE utf8_unicode_ci")

    create_table :orders do |t|
	    t.column :sort_order,	:integer, :null => false
	    t.column :latin_name,	:string, :null => false
    end

    add_index(:orders, :sort_order, :unique => true);
    add_index(:orders, :latin_name, :unique => true);
  end

  def self.down
    drop_table :orders
  end
end
