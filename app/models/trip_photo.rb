class TripPhoto < ActiveRecord::Base
  include Birdstack::Photo

  belongs_to :trip
  belongs_to :trip_photo_activity

  before_validation :fill_in_cached_values
  validates_presence_of :trip

  def fill_in_cached_values
    self.private = self.trip.andand.private
    self.user = self.trip.andand.user
  end

  # comment collection stuff
  belongs_to     :comment_collection
  before_create  :create_comment_collection
  after_save     :update_comment_collection_privacy

  # before_create
  def create_comment_collection
    c = TripPhotoCommentCollection.new(:title => self.user.login + "'s trip photo")
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
