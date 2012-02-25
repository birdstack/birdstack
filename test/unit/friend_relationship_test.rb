require File.dirname(__FILE__) + '/../test_helper'

class FriendRelationshipTest < ActiveSupport::TestCase
  context "A friend relationship" do
    setup do
      @fr = FriendRelationship.new
      @fr.user = users(:quentin)
    end

    should "not be to yourself" do
      @fr.friend = users(:quentin)
      assert !@fr.save
      assert @fr.errors.on(:friend_id)
    end

    should "not allow duplicates" do
      @fr.friend = users(:joe1)
      assert @fr.save

      @fr = FriendRelationship.new
      @fr.user = users(:quentin)
      @fr.friend = users(:joe1)
      assert !@fr.save
      assert @fr.errors.on(:friend_id)
    end
  end

  context "A new reciprocal relationship" do
    setup do
      assert FriendRelationship.create_reciprocal_relationship(users(:quentin), users(:joe1))
    end

    should "exist" do

      assert users(:quentin).friends.exists?(users(:joe1))
      assert users(:joe1).friends.exists?(users(:quentin))
    end

    should "be breakable" do
      assert FriendRelationship.destroy_reciprocal_relationship(users(:quentin), users(:joe1))

      assert !users(:quentin).friends.exists?(users(:joe1))
      assert !users(:joe1).friends.exists?(users(:quentin))
    end
  end
end
