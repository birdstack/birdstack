class ContactNotifier < ActionMailer::Base
	include Birdstack::Notifications

	def contact_form(contact, user, remote_ip)
		@recipients = CONTACT_FORM_RECIPIENTS
		@from = contact.email
		@subject = EMAIL_NOTIFICATION_PREFIX + ' Contact Form: ' + contact.subject
		@body[:contact] = contact
		@body[:user] = user
		@body[:remote_ip] = remote_ip
	end
end
