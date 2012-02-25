class ChangeImportForumDescription < ActiveRecord::Migration
	def self.up
		f = Forum.find_by_url('import-help')
		f.description = 'If you are having trouble importing data into Birdstack -- or if you are wondering how to begin -- ask Birdstack users who have been through the process before.'
		f.save!
	end

	def self.down
		throw ActiveRecord::IrreversibleMigration
	end
end
