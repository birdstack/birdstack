class CommentMailer < ActionMailer::Base
  include Birdstack::Notifications

  def comment(recipient, comment)
    setup_email(recipient)

    title = comment.comment_collection.mail_notification_title

    if(recipient == comment.comment_collection.user) then
      @subject += comment.user.login + ' commented on your ' + title
    elsif(comment.user == comment.comment_collection.user) then
      pronoun = 
        if(comment.user.gender.blank?) then
          'their'
        elsif(comment.user.gender == 'm') then
          'his'
        else
          'her'
        end
      @subject += comment.user.login + " commented on #{pronoun} #{title}"
    else
      @subject += comment.user.login + " commented on #{comment.comment_collection.user.login}'s #{title}"
    end

    @body[:comment] = comment
  end
end
