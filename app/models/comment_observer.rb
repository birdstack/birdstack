class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    comment.notify_list.each do |user|
      CommentMailer.deliver_comment(user, comment)
    end
  end
  handle_asynchronously :after_create
end
