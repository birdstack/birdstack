class MessageReferenceMailer < ActionMailer::Base
	include Birdstack::Notifications

	def message_reference(message_reference)
		setup_email(message_reference.user)
		@subject += message_reference.message.user.login + ' sent you a message'

		@body[:message] = message_reference.message
	end
end
