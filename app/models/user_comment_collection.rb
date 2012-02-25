class UserCommentCollection < CommentCollection
	# We don't need to specify an association with a user here because the comment collection
	# is already owned by the user

	def mail_notification_title
          'profile'
	end

	def self.notify_property
          :notify_profile_comment
	end
end
