require 'digest/sha1'

class RememberMeCookie < ActiveRecord::Base
	belongs_to	:user

	before_validation_on_create :generate_token

	validates_presence_of	:user_id, :token, :expires_at
	validates_numericality_of :user_id

	private

	def generate_token
		self.token = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{rand.to_s}--#{self.object_id.to_s}--#{user.id}")
		self.expires_at = Time.now + REMEMBER_ME_COOKIE_DURATION
	end
end
