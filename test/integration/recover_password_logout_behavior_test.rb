require "#{File.dirname(__FILE__)}/../test_helper"

class RecoverPasswordLogoutBehaviorTest < ActionController::IntegrationTest
	fixtures :users, :password_recovery_codes

	def test_log_out_on_valid_code
		post '/account/login', :login => 'quentin', :password => 'testing123456'
		assert_equal users(:quentin).id, session[:user] 
		assert_response :redirect

		get '/recover_password/code/' + password_recovery_codes(:quentin_valid).code
		assert_response :success
		assert_nil session[:user]
	end

	def test_log_out_on_invalid_code
		post '/account/login', :login => 'quentin', :password => 'testing123456'
		assert_equal users(:quentin).id, session[:user] 
		assert_response :redirect

		get '/recover_password/code/cheese'
		assert_response :redirect
		assert_nil session[:user]
	end
end
