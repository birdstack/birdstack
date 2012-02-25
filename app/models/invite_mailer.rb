class InviteMailer < ActionMailer::Base
	def invite(invite)
		@recipients = invite.to_emails
		@from = "\"#{invite.name.gsub('"','\"')}\" <#{invite.user.email}>"
		@subject = invite.subject

		@body[:body] = invite.body
	end
end
