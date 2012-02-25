class TaxonomyUpgradePrep < ActiveRecord::Migration
	def self.up
		add_column 'changes', 'type', :string, :null => false
		add_column 'users', 'pending_taxonomy_changes', :boolean, :null => false, :default => false
		change_column 'changes', 'description', :text, :null => false
	end

	def self.down
		remove_column 'changes', 'type'
		add_column 'users', 'pending_taxonomy_changes'
	end
end
