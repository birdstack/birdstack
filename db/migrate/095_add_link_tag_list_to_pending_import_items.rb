class AddLinkTagListToPendingImportItems < ActiveRecord::Migration
  def self.up
	  add_column :pending_import_items, 'link', :text
	  add_column :pending_import_items, 'tag_list', :text
  end

  def self.down
	  remove_column :pending_import_items, 'tag_list', :text
	  remove_column :pending_import_items, 'link', :text
  end
end
