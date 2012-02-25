class SightingCommentCollection < CommentCollection
	has_one :sighting, :foreign_key => 'comment_collection_id'

	def mail_notification_title
            'observation'
	end

	def self.notify_property
            :notify_sighting_comment
	end
end
