require File.dirname(__FILE__) + '/../test_helper'
require 'recover_password_controller'

# Re-raise errors caught by the controller.
class RecoverPasswordController; def rescue_action(e) raise e end; end

class RecoverPasswordControllerTest < ActionController::TestCase

	fixtures :users, :password_recovery_codes

  def setup
    @controller = RecoverPasswordController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @emails	= ActionMailer::Base.deliveries
    @emails.clear
  end

	def test_invalid_username
		post :index, :login_or_email => 'cheese'
		assert_equal 2, PasswordRecoveryCode.count
	end

	def test_valid_username
		post :index, :login_or_email => 'quentin'
		assert_equal 3, PasswordRecoveryCode.count
		assert_equal 1, @emails.length
	end

	def test_valid_email
		post :index, :login_or_email => 'quentin@example.com'
		assert_equal 3, PasswordRecoveryCode.count
		assert_equal 1, @emails.length
	end

	def test_invalid_code
		get :code, :id => 'cheese'
		assert_response :redirect
		assert flash.has_key?(:warning)
	end

	def test_expired_code
		code = password_recovery_codes(:quentin_expired)
		get :code, :id => code.code
		assert_response :redirect
		assert flash.has_key?(:warning)
		assert_equal 1, PasswordRecoveryCode.count
	end

	def test_valid_code
		code = password_recovery_codes(:quentin_valid)
		get :code, :id => code.code
		assert_response :success
		assert !flash.has_key?(:warning)
	end

	def test_actually_reset_password
		code = password_recovery_codes(:quentin_valid)
		post :code, :id => code.code, :password => 'cheese123456', :password_confirmation => 'cheese123456'
		assert_response :redirect
		assert flash.has_key?(:notice)
		assert_equal 1, PasswordRecoveryCode.count
	end
end
