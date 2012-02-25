require File.dirname(__FILE__) + '/../test_helper'

class FriendRequestTest < ActiveSupport::TestCase
  context "a friend request" do
    setup do
      @fr = FriendRequest.new
      @fr.user = users(:quentin)
    end

    should "not be to yourself" do
      @fr.potential_friend = users(:quentin)
      
      assert !@fr.save
      assert @fr.errors.on(:potential_friend)
    end

    should "not allow dups" do
      @fr.potential_friend = users(:joe1)
      assert @fr.save

      @fr = FriendRequest.new
      @fr.user = users(:quentin)
      @fr.potential_friend = users(:joe1)
      assert !@fr.save
      assert @fr.errors.on(:potential_friend)
    end

    should "allow multiple requests for different users" do
      @fr.potential_friend = users(:joe1)
      assert @fr.save

      @fr = FriendRequest.new
      @fr.user = users(:anotherjoe)
      @fr.potential_friend = users(:joe1)
      assert @fr.save
    end

    should "not allow a request in the other direction" do
      @fr.potential_friend = users(:joe1)
      assert @fr.save

      @fr = FriendRequest.new
      @fr.user = users(:joe1)
      @fr.potential_friend = users(:quentin)
      assert !@fr.save
      assert @fr.errors.on(:potential_friend)
    end

    should "not be allowed for a user who is already your friend" do
      u1 = users(:quentin)
      u2 = users(:joe1)
      u1.friends << u2
      assert u1.save
      u2.friends << u1
      assert u2.save

      @fr.potential_friend = u2
      assert !@fr.save
      assert @fr.errors.on(:potential_friend)
    end

    should "update cached count" do
      @fr.potential_friend = users(:joe1)
      assert_difference users(:quentin), :pending_friend_requests do
        @fr.save!
      end
      assert_difference users(:quentin), :pending_friend_requests, -1 do
        @fr.destroy
      end
    end

    context "that is completed" do
      setup do
        @fr.potential_friend = users(:joe1)
        assert @fr.save
      end

      should "return the requesting user" do
        assert_equal users(:joe1), FriendRequest.request_exists?(users(:joe1), users(:quentin))
        assert_equal users(:joe1), FriendRequest.request_exists?(users(:quentin), users(:joe1))
      end
    end

    context "that is completed the other direction" do
      setup do
        @fr.user = users(:joe1)
        @fr.potential_friend = users(:quentin)
        assert @fr.save
      end

      should "return the requesting user" do
        assert_equal users(:quentin), FriendRequest.request_exists?(users(:joe1), users(:quentin))
        assert_equal users(:quentin), FriendRequest.request_exists?(users(:quentin), users(:joe1))
      end
      
      should "return false for a request that doesn't exist" do
        assert_nil FriendRequest.request_exists?(users(:quentin), users(:anotherjoe))
        assert_nil FriendRequest.request_exists?(users(:anotherjoe), users(:quentin))
      end
    end
  end
end
