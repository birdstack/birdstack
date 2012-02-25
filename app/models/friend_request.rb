class FriendRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :potential_friend, :class_name => 'User'

  attr_accessible :message

  validates_presence_of :potential_friend_id
  validates_presence_of :user_id

  # REMEMBER: user is whom the request is TO, potential_friend is whom the request is FROM

  def validate
    # We can't validate if this isn't set.  It's checked above.
    return if potential_friend.nil?

    if(potential_friend == user) then
      errors.add(:potential_friend, "cannot be yourself")
    end

    if(user.friends.exists?(potential_friend.id)) then
      errors.add(:potential_friend, "is already your friend")
    end

    if(requester = FriendRequest.request_exists?(user, potential_friend)) then
      if(requester == user) then
        errors.add(:potential_friend, "has already requested to be your friend")
      elsif(requester == potential_friend) then
        errors.add(:potential_friend, "already has a friend request from you")
      else
        raise "This shouldn't happen!"
      end
    end
  end

  # The users can be specified in either order.  Returns the user that made the request.
  def self.request_exists?(user1, user2)
    if(user1.friend_requests.exists?(:potential_friend_id => user2.id)) then
      return user2
    elsif(user2.friend_requests.exists?(:potential_friend_id => user1.id)) then
      return user1
    else
      return nil
    end
  end

  def after_save
    update_cache
  end

  def after_destroy
    update_cache
  end

  def update_cache
    user.pending_friend_requests = user.friend_requests.size
    user.save!
  end
end
