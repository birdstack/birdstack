require "#{File.dirname(__FILE__)}/../test_helper"

class RedirectTest < ActionController::IntegrationTest
	def test_main_redirect
		get '/main/about'
		assert_redirected_to '/about'
		assert_equal '301 Moved Permanently', response.status
	end

	def test_observation_redirect
		get '/observation/add'
		assert_redirected_to '/sighting/add'
		assert_equal '301 Moved Permanently', response.status
	end

	def test_main_redirect_no_action
		get '/main'
		assert_redirected_to '/'
		assert_equal '301 Moved Permanently', response.status
	end
end
