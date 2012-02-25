class NotificationFlagMailer < ActionMailer::Base
	include Birdstack::Notifications

	def notification_flag(notification_flag)
		@recipients = CONTACT_FORM_RECIPIENTS
		@from = notification_flag.email
		@subject = EMAIL_NOTIFICATION_PREFIX + ' Notification Flag For: ' + notification_flag.notification.species.english_name

		@body[:notification_flag] = notification_flag
	end
end
