class PasswordRecoveryCodeNotifier < ActionMailer::Base
	include Birdstack::Notifications

	def code_notification(password_recovery_code)
		setup_email(password_recovery_code.user)
		@subject += 'Password Recovery Instructions'
		@body[:password_recovery_code] = password_recovery_code
	end
end
