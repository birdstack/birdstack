class AccountController < ApplicationController
  skip_before_filter :login_required

  def index
    redirect_to(:controller => :main, :action => :index)
  end

  def login
    if logged_in? then
	    redirect_to(:controller => 'dashboard', :action => 'index')
	    flash[:notice] = "You are already logged in as " + current_user.login
	    return
    end

    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        set_remember_me_cookie
      end
     
      flash[:notice] = "Logged in successfully"

      if params[:redirect_to] then
	      redirect_to params[:redirect_to]
      else
	      redirect_to :controller => :dashboard, :action => :index
      end
    else
      # We want to retain where we were supposed to redirect to, but rendering the page clears that out of the session
      # So we set it here
      session[:redirect_to] = params[:redirect_to] if params[:redirect_to]

      flash.now[:warning] = "Invalid username or password"
      return
    end
  end

  def signup
    redirect_to(:controller => 'main', :action => 'index') if logged_in?

    @user = User.new(params[:user])
    return unless request.post?
    if @user.save_with_captcha
	    redirect_to(:action => 'next')
	    flash[:notice] = "Thanks for signing up!"
    else
	    render :action => 'signup'
    end
  end

  def activate
	  @user = User.find_by_activation_code(params[:id])
	  
	  # Activation successful:
	  if @user and @user.activate
		  self.current_user = @user
		  set_remember_me_cookie
		  redirect_to(:controller => 'dashboard', :action => 'index')
		  flash[:notice] = "Your account has been activated."
	  # Activation unsuccessful because it's their own, already-activated code!
	  elsif @user and logged_in? and @user.id == self.current_user.id
		  redirect_to(:controller => 'dashboard', :action => 'index')
	  # Activation unsuccessful, and it's not their code
	  else
		  logout_and_delete_remember_me
		  redirect_to(:controller => 'account', :action => 'signup')
		  flash[:warning] = "Unable to activate account."
	  end
  end

  # unsubscribe
  def us
    user = User.find_by_activation_code(params[:id])
    unless user then
      flash[:warning] = "Invalid unsubscribe code. Please contact us."
      redirect_to(:controller => :main, :action => 'index')
      return
    end

    notification = User::NOTIFICATION_TYPES.to_a.find {|n| n[1][:short] == params[:t] }
    unless notification then
      flash[:warning] = "Invalid unsubscribe type. Please contact us."
      redirect_to(:controller => :main, :action => 'index')
      return
    end

    user.write_attribute(notification[0], false)

    unless user.save then
      flash[:warning] = "Error unsubscribing. Please contact us."
    end

    flash[:notice]  = "#{user.email} has been unsubscribed from notifications about #{notification[1][:desc]}. To further modify your subscription options, log in and access the account settings page"
    redirect_to(:controller => :main, :action => 'index')
    return
  end

  def logout
    logout_and_delete_remember_me
    flash[:notice] = "You have been logged out."
    redirect_to(:controller => :main, :action => 'index')
  end
end
