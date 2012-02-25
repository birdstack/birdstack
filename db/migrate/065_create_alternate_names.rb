class CreateAlternateNames < ActiveRecord::Migration
  def self.up
    create_table :alternate_names do |t|
      t.integer :user_id, :null => false
      t.text :description, :null => false
      t.integer :species_id, :null => false
      t.string :name, :null => false
      t.string :search_name, :null => false

      t.timestamps
    end

    execute "ALTER TABLE alternate_names ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE alternate_names ADD CONSTRAINT FOREIGN KEY (species_id) REFERENCES species(id)"
  end

  def self.down
    drop_table :alternate_names
  end
end
