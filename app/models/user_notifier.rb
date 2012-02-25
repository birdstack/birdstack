class UserNotifier < ActionMailer::Base
  include Birdstack::Notifications

  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
  end
end
