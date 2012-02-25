class PendingImport < ActiveRecord::Base
	belongs_to :user
	has_many :pending_import_items, :dependent => :delete_all

	validates_presence_of :user_id
	validates_presence_of :filename

	attr_accessible :filename, :description

	def before_validation
		if self.filename.blank? then
			self.filename = 'untitled'
		end
	end
end
