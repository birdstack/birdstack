class AdministrativeNotifications < ActionMailer::Base
  def blocked_user(user, request)
    subject    "Login attempt from blocked user #{user.login}"
    recipients CONTACT_FORM_RECIPIENTS
    from       EMAIL_NOTIFICATION_FROM
    
    body       :user => user, :request => request
  end

end
