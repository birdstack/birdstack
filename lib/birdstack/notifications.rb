module Birdstack::Notifications
	private

	def setup_email(user)
		@recipients  = "#{user.email}"
		@from        = EMAIL_NOTIFICATION_FROM
		@subject     = EMAIL_NOTIFICATION_PREFIX + ' '
		@body[:user] = user
	end
end
