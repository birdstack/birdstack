class TripCommentCollection < CommentCollection
	has_one :trip, :foreign_key => 'comment_collection_id'

	def mail_notification_title
          'trip'
	end

	def self.notify_property
          :notify_trip_comment
	end
end
