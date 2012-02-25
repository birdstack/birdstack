class Invite < Tableless
	column :name,		:string
	column :subject,	:string
	column :body,		:string
	column :to_email,	:string
	column :user_id,	:integer

	belongs_to :user

	attr_accessible :name, :body, :subject, :to_email

	validates_presence_of	:name, :subject, :body, :user_id, :to_email

	attr_accessor :to_emails

	def validate
		@to_emails = []
		self.to_email.split(/\s*,\s*/).each do |email|
			unless email =~ RFC822::EmailAddress then
				errors.add(:to_email, 'is invalid')
				break
			end
			@to_emails << email
		end
	end
end
