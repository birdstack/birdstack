require File.dirname(__FILE__) + '/../test_helper'
require 'main_controller'

# Re-raise errors caught by the controller.
class MainController; def rescue_action(e) raise e end; end

class MainControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    @controller = MainController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @emails     = ActionMailer::Base.deliveries
    @emails.clear
  end

  def test_send_email_logged_in
	  login_as :quentin
	  post :contact, :contact => {:name => 'Quentin', :email => 'quentin@example.com', :subject => 'I love your site!', :body => 'Fjord rocks at life.'}

	  assert_response :success

	  assert_equal 1, @emails.length
	  assert(@emails.first.body =~ /Logged in as/)
	  assert(@emails.first.body =~ /Sent at/)
  end

  def test_send_email_not_logged_in
	  post :contact, :contact => {:name => 'Quentin', :email => 'quentin@example.com', :subject => 'I love your site!', :body => 'Fjord rocks at life.'}

	  assert_response :success

	  assert_equal 1, @emails.length
	  assert(@emails.first.body !~ /Logged in as/)
	  assert(@emails.first.body =~ /Sent at/)
  end
end
