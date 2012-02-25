class NotificationFlag < Tableless
	column :name,		:string
	column :email,		:string
	column :body,		:string
	column :user_id,	:integer
	column :notification_id, :integer

	belongs_to :user
	belongs_to :notification

	attr_accessible :name, :email, :body, :captcha, :captcha_code

	apply_simple_captcha

	validates_presence_of	:name, :email, :body, :notification_id
	validates_format_of	:email, :with => RFC822::EmailAddress
end
