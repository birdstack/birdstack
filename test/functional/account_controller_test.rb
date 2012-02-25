require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users
  fixtures :remember_me_cookies

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @emails	= ActionMailer::Base.deliveries
    @emails.clear
  end

  def test_should_redirect_when_already_signed_in
	  login_as :quentin
	  get :login

	  assert_response :redirect
	  assert_redirected_to :controller => 'dashboard', :action => 'index'
	  assert_equal "You are already logged in as quentin", @response.flash[:notice]
  end

  def test_should_login_and_redirect
    post :login, :login => 'quentin', :password => 'testing123456'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference User, :count do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference User, :count do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference User, :count do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference User, :count do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference User, :count do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_remember_me
    post :login, :login => 'quentin', :password => 'testing123456', :remember_me => "1"
    assert_not_nil @response.cookies[REMEMBER_ME_COOKIE_NAME.to_s]
    assert_response :redirect
    assert @controller.send(:logged_in?)
  end

  def test_should_not_remember_me
    post :login, :login => 'quentin', :password => 'testing123456', :remember_me => "0"
    assert_nil @response.cookies[REMEMBER_ME_COOKIE_NAME.to_s]
    assert_response :redirect
    assert @controller.send(:logged_in?)
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :logout
    assert_equal nil, @response.cookies[REMEMBER_ME_COOKIE_NAME.to_s]
  end

  def test_should_login_with_cookie
    @request.cookies[REMEMBER_ME_COOKIE_NAME.to_s] = auth_token(remember_me_cookies(:quentin).token)
    get :index
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_token_login
    @request.cookies["auth_token"] = auth_token(remember_me_cookies(:quentin_expired).token)
    get :index
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    @request.cookies[REMEMBER_ME_COOKIE_NAME.to_s] = auth_token('invalid_auth_token')
    get :index
    assert !@controller.send(:logged_in?)
  end

  def test_should_activate_user_and_send_activation_email
    get :activate, :id => users(:aaron).activation_code
    assert_equal 1, @emails.length
    assert(@emails.first.subject =~ /Your account has been activated/)
    assert(@emails.first.body    =~ /#{assigns(:user).login},/)
  end

  def test_should_send_activation_email_after_signup
    create_user
    assert_equal 1, @emails.length
    assert(@emails.first.body    =~ /account\/activate\/#{assigns(:user).activation_code}/)
  end

  def test_should_activate_user
    assert_nil User.authenticate('aaron', 'testing123456')
    get :activate, :id => users(:aaron).activation_code
    assert_equal users(:aaron), User.authenticate('aaron', 'testing123456')
  end

  def test_should_not_activate_nil
    get :activate, :id => nil
    assert_response :redirect
    assert flash.has_key?(:warning), "Flash should contain error message."
  end

  def test_should_not_activate_bad
    get :activate, :id => 'foobar'
    assert_response :redirect
    assert flash.has_key?(:warning), "Flash should contain error message."
  end

  def test_activation_should_expire
	  # Can't log in now for sure
    assert_nil User.authenticate('lazyjoe', 'testing123456')
    get :activate, :id => users(:lazyjoe).activation_code
    # He didn't do it quick enough, it should be expired
    assert_nil User.authenticate('lazyjoe', 'testing123456')
    # In fact, it should be plain gone
    assert_nil User.find_by_login(users(:lazyjoe).login)
  end

  def test_redirect_on_already_activated_code
    get :activate, :id => users(:quentin).activation_code
    assert_response :redirect
    assert flash.has_key?(:warning), "Flash should contain error message."
  end

  def test_block_user
    u = users(:quentin)
    u.blocked = true
    assert u.save

    login_as :quentin
    get :index

    assert_response :redirect
    assert_redirected_to :controller => 'main', :action => 'index'
    assert flash.has_key?(:warning)
    assert_equal 1, @emails.length
  end

  def test_unsubscribe_link
    u = users(:quentin)
    assert u.notify_newsletter
    get :us, :id => u.activation_code, :t => 'n'
    assert_response :redirect
    u.reload
    assert !u.notify_newsletter
  end

  protected
    def create_user(options = {})
      post :signup, :user => { :login => 'quire', :email => 'quire@example.com', :email_confirmation => 'quire@example.com', 
        :password => 'quire123456', :password_confirmation => 'quire123456' }.merge(options)
    end
    
    def auth_token(token)
      CGI::Cookie.new('name' => REMEMBER_ME_COOKIE_NAME.to_s, 'value' => token)
    end
end
