class FriendRelationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => 'User'

  validates_presence_of :user_id
  validates_presence_of :friend_id
  validates_uniqueness_of :friend_id, :scope => :user_id

  attr_accessible

  def validate
    if(user == friend) then
      errors.add(:friend, "may not be yourself")
    end
  end

  def self.create_reciprocal_relationship(user1, user2)
    begin
      FriendRelationship.transaction do
        unless user1.friends.exists?(user2.id) then
          user1.friends << user2
          user1.save!
        end
        unless user2.friends.exists?(user1.id) then
          user2.friends << user1
          user2.save!
        end
      end
    rescue
      return false
    end

    return true
  end

  def self.destroy_reciprocal_relationship(user1, user2)
    begin
      FriendRelationship.transaction do
        if user1.friends.exists?(user2.id) then
          user1.friends -= [user2]
          user1.save!
        end
        if user2.friends.exists?(user1.id) then
          user2.friends -= [user1]
          user2.save!
        end
      end
    rescue
      return false
    end

    return true
  end
end
