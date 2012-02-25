class ForumCommentCollection < CommentCollection
	# Due to our polymorphic nature, Rails gets confused about the table names
	# Or maybe I should have named the table differently.  Oh well.  This fixes it.
	has_and_belongs_to_many :forums, :join_table => 'comment_collections_forums', :foreign_key => 'comment_collection_id'

	# I wanted to use has_and_belongs_to_many so that the foreign keys could be in a separate table
	# because comment_collections are polymorphic, so having foreign keys there doesn't work so well.
	# But, that means the auto-generated helper method is called #forums and returns an array.  Since
	# we will always have only 1, this method is a cheating way to achieve that
	def forum
		self.forums[0]
	end

	def mail_notification_title
          "forum thread \"#{title}\""
	end

	def self.notify_property
            :notify_forum_comment
	end
end
