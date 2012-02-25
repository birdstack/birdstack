require File.dirname(__FILE__) + '/../test_helper'
require 'forums_controller'

# Re-raise errors caught by the controller.
class ForumsController; def rescue_action(e) raise e end; end

class ForumsControllerTest < ActionController::TestCase
  def setup
    @controller = ForumsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_post
    f = Forum.new(:name => 'testing', :description => 'test desc', :url => 'testing', :sort_order => 1)
    f.save!

    login_as :quentin

    assert_difference CommentCollection, :count do
      post :newthread,
        :forum => 'testing',
        :comment => {:comment => 'blarg'},
        :comment_collection => {:title => 'titleness'}

      assert_response :redirect
    end

    f.reload
    cc = f.comment_collections.first
    assert_equal 'titleness', cc.title
    assert_equal 1, cc.comments.size
    assert_equal 'blarg', cc.comments.first.comment
  end
end
