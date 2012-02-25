class CreateChanges < ActiveRecord::Migration
  def self.up
    create_table :changes do |t|
	    t.column :date,	:datetime, :null => false
	    t.column :description, :string, :null => false
    end
  end

  def self.down
    drop_table :changes
  end
end
