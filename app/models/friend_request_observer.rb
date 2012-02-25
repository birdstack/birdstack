class FriendRequestObserver < ActiveRecord::Observer
  def after_create(friend_request)
    # Send it only if they want notifications
    if friend_request.user.notify_friend_request then
      FriendRequestMailer.deliver_friend_request(friend_request)
    end
  end
end
