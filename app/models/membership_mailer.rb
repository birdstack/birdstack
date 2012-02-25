class MembershipMailer < ActionMailer::Base
	include Birdstack::Notifications

	def membership(user)
		setup_email(user)
		@subject = "Birdstack Supporting Membership Expires Soon"
	end
end
