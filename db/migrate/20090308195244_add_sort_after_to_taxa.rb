class AddSortAfterToTaxa < ActiveRecord::Migration
  def self.up
    # This used to be a unique index, which could mess us up now
    # Also, I don't think indexing the sort order will really help us
    remove_index :species, :sort_order
    remove_index :genera, :sort_order
    remove_index :families, :sort_order
    remove_index :orders, :sort_order

    add_column :species, :sort_after_id, :integer
    execute "ALTER TABLE species ADD CONSTRAINT FOREIGN KEY (sort_after_id) REFERENCES species(id)"
    add_column :genera, :sort_after_id, :integer
    execute "ALTER TABLE genera ADD CONSTRAINT FOREIGN KEY (sort_after_id) REFERENCES genera(id)"
    add_column :families, :sort_after_id, :integer
    execute "ALTER TABLE families ADD CONSTRAINT FOREIGN KEY (sort_after_id) REFERENCES families(id)"
    add_column :orders, :sort_after_id, :integer
    execute "ALTER TABLE orders ADD CONSTRAINT FOREIGN KEY (sort_after_id) REFERENCES orders(id)"
  end

  def self.down
    remove_column :species, :sort_after_id
    remove_column :genera, :sort_after_id
    remove_column :families, :sort_after_id
    remove_column :orders, :sort_after_id

    add_index :species, :sort_order, :unique => true
    add_index :genera, :sort_order, :unique => true
    add_index :families, :sort_order, :unique => true
    add_index :orders, :sort_order, :unique => true
  end
end
