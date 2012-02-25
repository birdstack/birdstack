class UserLocationPhotoCommentCollection < CommentCollection
  has_one :user_location_photo, :foreign_key => 'comment_collection_id'

  def self.mail_notification_title
    'location photo'
  end

  def self.notify_property
    :notify_photo_comment
  end
end
