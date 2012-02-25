class MessageObserver < ActiveRecord::Observer
  def after_create(message)
    message.conversation.users.each do |u|
      mr = MessageReference.new
      mr.user = u
      mr.message = message
      mr.save!
    end
  end
end
