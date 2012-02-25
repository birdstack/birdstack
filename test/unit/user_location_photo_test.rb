require File.dirname(__FILE__) + '/../test_helper'

class UserLocationPhotoTest < ActiveSupport::TestCase
  # UserLocation photo privacy is a special case because locations have more than one privacy level
  context "A valid public location photo" do
    setup do
      @l = users(:quentin).user_locations.first
      @l.private = 0
      @l.save!
      @lp = @l.user_location_photo.build
      @lp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      @lp.title = 'test'
      @lp.license = 'all-rights-reserved'
      @lp.save!
      UserLocationPhoto.do_post_process(@lp.id)
    end

    should "be accessible" do
      assert !@lp.private
      assert !@lp.comment_collection.private
      assert @lp.user == @l.user

      assert @lp.photo.path =~ /public/
      assert File.exist?(@lp.photo.path)
    end

    should "be visible to everyone" do
      assert @lp.publicize!(false)
    end

    context "that has been made fully private" do
      setup do
        @l.reload
        @l.private = 2
        @l.save!
        @lp = UserLocationPhoto.find(@lp.id)
      end

      should "be accessible" do
        assert @lp.private
        assert @lp.comment_collection.private
        assert @lp.user == @l.user

        assert @lp.photo.path =~ /private/
        assert File.exist?(@lp.photo.path)
      end

      should "be visible to its owner" do
        assert @lp.publicize!(@l.user)
      end

      should "not be visible to everyone" do
        assert_raise RuntimeError do
          @lp.publicize!(false)
        end
      end

      context "that has been made partially private" do
        setup do
          @l.reload
          @l.private = 1
          @l.save!
          @lp = UserLocationPhoto.find(@lp.id)
        end

        should "be accessible" do
          assert !@lp.private
          assert !@lp.comment_collection.private
          assert @lp.user == @l.user

          assert @lp.photo.path =~ /public/
          assert File.exist?(@lp.photo.path)
        end
      end
    end
  end
end
