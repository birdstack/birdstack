class CreatePendingImportItems < ActiveRecord::Migration
  def self.up
    create_table :pending_import_items do |t|
      t.string :english_name, :null => false
      t.string :location_name
      t.integer :date_year
      t.integer :date_month
      t.integer :date_day
      t.string :trip_name
      t.integer :time_hour
      t.integer :time_minute
      t.integer :species_count
      t.text :notes
      t.integer :juvenile_male
      t.integer :juvenile_female
      t.integer :juvenile_unknown
      t.integer :immature_male
      t.integer :immature_female
      t.integer :immature_unknown
      t.integer :adult_male
      t.integer :adult_female
      t.integer :adult_unknown
      t.integer :unknown_male
      t.integer :unknown_female
      t.integer :unknown_unknown
      t.integer :line
      t.integer :pending_import_id, :null => false

      t.timestamps
    end

    execute "ALTER TABLE pending_import_items ADD CONSTRAINT FOREIGN KEY (pending_import_id) REFERENCES pending_imports(id)"
  end

  def self.down
    drop_table :pending_import_items
  end
end
