class SightingPhoto < ActiveRecord::Base
  include Birdstack::Photo

  belongs_to :sighting
  belongs_to :species
  belongs_to :sighting_photo_activity
  belongs_to :trip
  belongs_to :user_location

  named_scope :species_id, lambda { |species_id|
    {:conditions => {:species_id => species_id}}
  }
  
  named_scope :trip_id, lambda { |trip_id|
    {:conditions => {:trip_id => trip_id}}
  }

  named_scope :user_location_id, lambda { |user_location_id|
    {:conditions => {:user_location_id => user_location_id}}
  }

  before_validation :fill_in_cached_values
  validates_presence_of :sighting

  def fill_in_cached_values
    self.private = self.sighting.andand.private
    self.user = self.sighting.andand.user
    self.species = self.sighting.andand.species
    self.trip = self.sighting.andand.trip
    self.user_location = self.sighting.andand.user_location
  end

  # comment collection stuff
  belongs_to     :comment_collection
  before_create  :create_comment_collection
  after_save     :update_comment_collection_privacy

  # before_create
  def create_comment_collection
    c = SightingPhotoCommentCollection.new(:title => self.user.login + "'s observation photo")
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
