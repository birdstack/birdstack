class AddNewInitialForums < ActiveRecord::Migration
	def self.up
		# It's easier to just modify these existing ones
		f = Forum.find_by_sort_order(0)
		f.name = 'Help Using Birdstack (How do I...?)'
		f.description = 'Stumped? Other Birdstack members can help you with your questions. Please note that the Birdstack administrators may browse this forum periodically but cannot respond to every post.'
		f.url = 'help-using-birdstack'
		f.save!

		f = Forum.find_by_sort_order(1)
		f.name = 'Bird Name and ID Help'
		f.description = 'If you can\'t find a bird name in the Birdstack database, or if you need help identifying a bird, someone may be able to help you here.'
		f.url = 'bird-name-id-help'
		f.save!

		Forum.create(:name => 'Help with Geocoding', :description => 'Do you have questions about Birdstack\'s geocoding features? Other Birdstack members may be able to help.', :url => 'geocoding-help', :sort_order => '2')

		Forum.create(:name => 'Off Topic', :description => 'Converse. Opine. Laugh. Cry. Rant. Whine. Gush. Cheep, chirp, and twitter.', :url => 'off-topic', :sort_order => '3')
	end

	def self.down
		throw ActiveRecord::IrreversibleMigration
	end
end
