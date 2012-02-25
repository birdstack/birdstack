require File.dirname(__FILE__) + '/../test_helper'
require 'comment_controller'

# Re-raise errors caught by the controller.
class CommentController; def rescue_action(e) raise e end; end

class CommentControllerTest < ActionController::TestCase
  fixtures :users, :comments, :comment_collections

  def setup
    @controller = CommentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_can_edit_own
	  login_as :quentin

	  post :edit, :id => 3, :comment => {:comment => 'updated!'}

	  assert_equal 'updated!', Comment.find(3).comment
  end

  def test_cant_edit_not_own
	  login_as :quentin

	  post :edit, :id => 4, :comment => {:comment => 'updated!'}

	  assert_equal 'blah blah blah', Comment.find(4).comment
	  assert flash[:warning]
	  assert_response :redirect
  end

  def test_can_delete_own
	  login_as :quentin

	  post :delete, :id => 3

	  assert_equal true, Comment.find(3).deleted
  end

  def test_can_delete_own_but_not_on_get
	  login_as :quentin

	  get :delete, :id => 3

	  assert_equal false, Comment.find(3).deleted
  end

  def test_cant_delete_not_own
	  login_as :quentin

	  post :delete, :id => 4

	  assert_equal false, Comment.find(4).deleted
	  assert flash[:warning]
	  assert_response :redirect
  end

  def test_can_permanently_delete_own
	  login_as :quentin

	  assert_difference Comment, :count, -1 do
		  post :permanently_delete, :id => 4
	  end
  end

  def test_cant_permanently_delete_not_own
	  login_as :quentin

	  post :permanently_delete, :id => 5

	  assert Comment.find(5)
	  assert flash[:warning]
	  assert_response :redirect
  end
end
