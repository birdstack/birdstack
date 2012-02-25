class IgnoredNotification < ActiveRecord::Base
	attr_accessible

	belongs_to :user
	belongs_to :notification

	validates_uniqueness_of :notification_id, :scope => :user_id
end
