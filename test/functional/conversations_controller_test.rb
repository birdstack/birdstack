require File.dirname(__FILE__) + '/../test_helper'

class ConversationsControllerTest < ActionController::TestCase
  context "A new conversation" do
    setup do
      login_as :quentin
      assert_difference MessageReference, :count, 2 do
        post :start, :conversation => {:subject => 'test', :participants_text => 'joe1'}, :message => {:body => 'test'}
        assert_response :redirect
        assert !flash[:warning]
      end
    end

    should "allow a delete of nothing" do
      assert_no_difference MessageReference, :count do
        post :modify 
      end
      assert_response :redirect
    end

    should "allow a delete of a message" do
      assert_difference MessageReference, :count, -1 do
        post :modify, :message_references => {users(:quentin).message_references[0].id => 1}
      end
      assert_response :redirect
    end
  end
end
