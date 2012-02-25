class AddImportForum < ActiveRecord::Migration
	def self.up
		f = Forum.find_by_sort_order(3)
		f.sort_order = 4
		f.save!

		Forum.create(:name => 'Help with Import', :description => 'If you are having trouble importing sightings into Birdstack -- or if you are wondering how to begin -- ask Birdstack users who have been through the process before.', :url => 'import-help', :sort_order => '3')
	end

	def self.down
		throw ActiveRecord::IrreversibleMigration
	end
end
