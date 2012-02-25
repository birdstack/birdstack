class NewsletterMailer < ActionMailer::Base
	include Birdstack::Notifications

	def newsletter(subject, newsletter, user)
		setup_email(user)
		@subject = subject

		@body[:newsletter] = newsletter
	end
end
