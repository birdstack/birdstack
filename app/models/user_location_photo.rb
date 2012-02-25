class UserLocationPhoto < ActiveRecord::Base
  include Birdstack::Photo

  belongs_to :user_location
  belongs_to :user_location_photo_activity

  before_validation :fill_in_cached_values
  validates_presence_of :user_location

  def fill_in_cached_values
    # Locations have multiple privacy levels
    self.private = (self.user_location.andand.private == 2)
    self.user = self.user_location.andand.user
  end

  # comment collection stuff
  belongs_to     :comment_collection
  before_create  :create_comment_collection
  after_save     :update_comment_collection_privacy

  # before_create
  def create_comment_collection
    c = UserLocationPhotoCommentCollection.new(:title => self.user.login + "'s location photo")
    c.user = self.user
    c.save!
    self.comment_collection = c
  end

  # after_save
  def update_comment_collection_privacy
    if(self.private_changed?) then
      c = self.comment_collection
      c.private = self.private
      c.save
    end
  end
end
