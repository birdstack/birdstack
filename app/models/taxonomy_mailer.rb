class TaxonomyMailer < ActionMailer::Base
	include Birdstack::Notifications

	def taxonomy_changes(user, url)
		setup_email(user)
		@subject += "You have pending taxonomic changes at Birdstack"

		@body[:changes] = user.find_pending_taxonomy_changes
    @body[:url] = url
	end
end
