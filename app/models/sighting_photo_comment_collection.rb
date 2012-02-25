class SightingPhotoCommentCollection < CommentCollection
	has_one :sighting_photo, :foreign_key => 'comment_collection_id'

	def mail_notification_title
          'observation photo'
	end

	def self.notify_property
          :notify_photo_comment
	end
end
