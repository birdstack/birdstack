class AlternateNameFlagMailer < ActionMailer::Base
	include Birdstack::Notifications

	def alternate_name_flag(alternate_name_flag)
		@recipients = CONTACT_FORM_RECIPIENTS
		@from = alternate_name_flag.email
		@subject = EMAIL_NOTIFICATION_PREFIX + ' Alternate Name Flag For: ' + alternate_name_flag.alternate_name.species.english_name

		@body[:alternate_name_flag] = alternate_name_flag
	end
end
