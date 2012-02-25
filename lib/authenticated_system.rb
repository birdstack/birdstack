module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      current_user != :false
    end
    
    # Accesses the current user from the session.
    def current_user
      unless @current_user then
	      @current_user = (session[:user] && User.find_by_id(session[:user])) || :false
	      if @current_user == :false then
		      logger.info 'No logged in user'
	      else
		      logger.info "User #{@current_user.login} (#{@current_user.id})"
	      end
      end

      @current_user
    end
    
    # Store the given user in the session.
    def current_user=(new_user)
      return if new_user.nil? || new_user.is_a?(Symbol) || new_user.activated_at.nil?

      session[:user] = new_user.id
      @current_user = new_user
    end

    def check_blocked_user
      if(logged_in? and current_user.blocked) then
        AdministrativeNotifications.deliver_blocked_user(current_user, request)
        logout_and_delete_remember_me
        flash[:warning] = "The account #{current_user.login} has been suspended because of a violation of the terms of service.  If you think this is a mistake, please contact us via the Contact page."
        redirect_to :controller => 'main', :action => 'index'
      end
    end
    
    # Check if the user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_user.login != "bob"
    #  end
    def authorized?
      true
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      if(logged_in? && authorized?) then
          true
      else
        access_denied
      end
    end
    
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
	  flash[:warning] = "The page you are trying to access requires a signed in user.  Please sign in."
	  session[:redirect_to] = request.request_uri
	  redirect_to :controller => 'account', :action => 'login'
    end  
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[REMEMBER_ME_COOKIE_NAME] && !logged_in?

      cookie = RememberMeCookie.find_by_token(cookies[REMEMBER_ME_COOKIE_NAME])
      return unless cookie

      if cookie.expires_at < Time.now
	      cookie.destroy
      else
	      if cookie.user
		cookie.expires_at = Time.now + REMEMBER_ME_COOKIE_DURATION
		cookie.save!
		self.current_user = cookie.user
	      end
      end
    end

    def set_remember_me_cookie
	cookie = RememberMeCookie.new
	cookie.user = current_user
	cookie.save!

        cookies[REMEMBER_ME_COOKIE_NAME] = { :value => cookie.token, :expires => cookie.expires_at, :httponly => true }
    end

    def logout_and_delete_remember_me
	    if(cookies[REMEMBER_ME_COOKIE_NAME])
		    cookie = RememberMeCookie.find_by_token(cookies[REMEMBER_ME_COOKIE_NAME])
		    cookie.destroy if cookie
	    end
	    cookies.delete REMEMBER_ME_COOKIE_NAME
	    if current_user != :false then
		    reset_session
	    end
    end
end
