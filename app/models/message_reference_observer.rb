class MessageReferenceObserver < ActiveRecord::Observer
  def after_create(message_reference)
    # Send it only if they want notifications and they weren't the one who
    # sent the message in the first place
    if message_reference.user.notify_message and message_reference.message.user != message_reference.user then
      MessageReferenceMailer.deliver_message_reference(message_reference)
    end
  end

  def after_destroy(message_reference)
    # See if we can delete the conversation
    unless(MessageReference.find(:first, :conditions => ['conversations.id = ?', message_reference.message.conversation.id], :joins => 'LEFT JOIN messages ON message_references.message_id = messages.id LEFT JOIN conversations ON messages.conversation_id = conversations.id')) then
      # No references exist
      message_reference.message.conversation.destroy
    end
  end
end
