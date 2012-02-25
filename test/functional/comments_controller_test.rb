require File.dirname(__FILE__) + '/../test_helper'
require 'comments_controller'

# Re-raise errors caught by the controller.
class CommentsController; def rescue_action(e) raise e end; end

class CommentsControllerTest < ActionController::TestCase
  fixtures :comment_collections, :users

  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_post
	  login_as :quentin
	  
	  assert_difference Comment, :count do
		  post :post, :id => 1, :comment => {:comment => 'test'}
	  end
  end

  def test_private_trip_feed
	  t = Trip.new(:name => 'awesome and beans')
	  t.user = users(:quentin)
	  t.private = true
	  t.save!

	  get :feed, :id => t.comment_collection.id
	  assert_response :redirect
  end

  def test_private_trip_feed_logged_in
	  t = Trip.new(:name => 'awesome and beans')
	  t.user = users(:quentin)
	  t.private = true
	  t.save!

	  login_as :quentin
	  get :feed, :id => t.comment_collection.id
	  assert_response :success
  end
end
