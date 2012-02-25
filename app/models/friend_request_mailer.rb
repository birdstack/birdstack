class FriendRequestMailer < ActionMailer::Base
	include Birdstack::Notifications

	def friend_request(friend_request)
		setup_email(friend_request.user)
		@subject += friend_request.potential_friend.login + ' sent you a friend request'

		@body[:friend_request] = friend_request
	end
end
