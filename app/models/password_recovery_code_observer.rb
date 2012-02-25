class PasswordRecoveryCodeObserver < ActiveRecord::Observer
	def after_create(password_recovery_code)
		PasswordRecoveryCodeNotifier.deliver_code_notification(password_recovery_code)
	end
end
