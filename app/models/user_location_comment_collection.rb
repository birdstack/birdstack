class UserLocationCommentCollection < CommentCollection
  has_one :user_location, :foreign_key => 'comment_collection_id'

  def mail_notification_title
    'location'
  end

  def self.notify_property
    :notify_user_location_comment
  end
end
