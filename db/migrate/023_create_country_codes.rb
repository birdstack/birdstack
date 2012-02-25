class CreateCountryCodes < ActiveRecord::Migration
  def self.up
    create_table :country_codes do |t|
	    t.column :cc,	:string, :null => false
	    t.column :name,	:string, :null => false
    end

    add_index :country_codes, :cc, :unique => true
  end

  def self.down
    drop_table :country_codes
  end
end
