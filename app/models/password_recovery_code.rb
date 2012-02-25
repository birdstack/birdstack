class PasswordRecoveryCode < ActiveRecord::Base
	belongs_to :user

	before_validation_on_create :generate_code

	validates_presence_of	:user_id, :code
	validates_numericality_of :user_id

	private

	def generate_code
		self.code = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{rand.to_s}--#{self.object_id.to_s}--#{user.id}")
	end
end
