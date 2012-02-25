require File.dirname(__FILE__) + '/../test_helper'
require 'people_controller'

# Re-raise errors caught by the controller.
class PeopleController; def rescue_action(e) raise e end; end

class PeopleControllerTest < ActionController::TestCase
  def setup
    @controller = PeopleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

	fixtures :users, :comment_collections, :comments

	def test_signature_length
		login_as :quentin
		too_long = '1'
		(1..1000).each { too_long += '1' }
		post :edit, :login => users(:quentin).login, :user => { :signature => too_long }

		# If it succeeded, we'd get a redirect
		assert_response :success
	end

	def test_invalid_user_redir
		get :view, :login => 'invalidnotauser'

		assert_response :redirect
		assert_equal 'people', @response.redirected_to[:controller]
		assert_equal 'view', @response.redirected_to[:action]
		assert_nil @response.redirected_to[:login]
	end

	def test_html_sanitization
		get :view, :login => users(:quentin).login

		assert_response :success
		assert @response.body.index("<p>Yay for <b>cheese</b> blah</p>")
	end

	def test_delete_pic
		login_as :quentin

		assert users(:quentin).profile_pic

		post :edit, :login => users(:quentin).login, :profile_pic_delete => 1

		users(:quentin).reload

		assert_equal nil, users(:quentin).profile_pic_file_name
	end

	def test_redir_on_edit_not_logged_in
		get :edit, :login => users(:quentin).login

		assert_response :redirect
		assert_equal 'account', @response.redirected_to[:controller]
		assert_equal 'login', @response.redirected_to[:action]
	end
end
