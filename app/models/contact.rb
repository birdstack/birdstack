class Contact < Tableless
	column :name,		:string
	column :email,		:string
	column :subject,	:string
	column :body,		:string

	apply_simple_captcha


	validates_presence_of	:name, :email, :subject, :body
	validates_format_of	:email, :with => RFC822::EmailAddress
end
