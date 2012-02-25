require "#{File.dirname(__FILE__)}/../test_helper"

class EmailActivationLogoutBehaivorTest < ActionController::IntegrationTest
  fixtures :users

  # Replace this with your real tests.
  def test_truth
    assert true
  end

	def test_log_out_on_valid_activation_code
		post '/account/login', :login => 'quentin', :password => 'testing123456'
		assert_equal users(:quentin).id, session[:user] 
		assert_response :redirect

		get '/account/activate/' + users(:aaron).activation_code
		assert_response :redirect
		assert_equal users(:aaron).id, session[:user]
	end

	def test_log_out_on_invalid_activation_code
		post '/account/login', :login => 'quentin', :password => 'testing123456'
		assert_equal users(:quentin).id, session[:user] 
		assert_response :redirect

		get '/account/activate/cheeseburger'
		assert_response :redirect
		assert_nil session[:user]
	end

	def test_dont_log_out_on_valid_activation_code_but_already_activated
		post '/account/login', :login => 'quentin', :password => 'testing123456'
		assert_equal users(:quentin).id, session[:user] 
		assert_response :redirect

		get '/account/activate/' + users(:aaron).activation_code
		assert_response :redirect
		assert_equal users(:aaron).id, session[:user]

		# Do it a second time. Should not log out
		get '/account/activate/' + users(:aaron).activation_code
		assert_response :redirect
		assert_equal users(:aaron).id, session[:user]
	end
end
