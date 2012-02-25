class TripPhotoCommentCollection < CommentCollection
	has_one :trip_photo, :foreign_key => 'comment_collection_id'

	def mail_notification_title
          'trip photo'
	end

	def self.notify_property
          :notify_photo_comment
	end
end
