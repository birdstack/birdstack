require File.dirname(__FILE__) + '/../test_helper'

class SightingPhotoTest < ActiveSupport::TestCase
  context "A valid photo aaron doesn't own" do
    setup do
      s = users(:quentin).sightings.first
      @sp = s.sighting_photo.build
      @sp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      @sp.title = 'test'
      @sp.license = 'all-rights-reserved'
      @sp.save!
    end

    should "not be visible to him for progress updates" do
      assert_equal :failure, SightingPhoto.processing_status_for_user([@sp.id], users(:aaron))[@sp.id]
    end

    should "should be visible to the owner" do
      assert_equal :processing, SightingPhoto.processing_status_for_user([@sp.id], users(:quentin))[@sp.id]
    end

    should "pass processing" do
      assert_equal :processing, SightingPhoto.processing_status_for_user([@sp.id], users(:quentin))[@sp.id]
      SightingPhoto.do_post_process(@sp.id)
      assert_equal :success, SightingPhoto.processing_status_for_user([@sp.id], users(:quentin))[@sp.id]
    end
  end

  context "A bad photo" do
    setup do
      s = users(:quentin).sightings.first
      @sp = s.sighting_photo.build
      @sp.photo = File.new(File.dirname(__FILE__) + '/../data/bad_img.jpg')
      @sp.title = 'test'
      @sp.license = 'all-rights-reserved'
      @sp.save!
    end

    should "fail processing" do
      assert_equal :processing, SightingPhoto.processing_status_for_user([@sp.id], users(:quentin))[@sp.id]
      SightingPhoto.do_post_process(@sp.id)
      assert_equal :failure, SightingPhoto.processing_status_for_user([@sp.id], users(:quentin))[@sp.id]
    end
  end

  context "A valid public photo" do
    setup do
      @s = users(:quentin).sightings.first
      @s.private = false
      @s.save!
      @sp = @s.sighting_photo.build
      @sp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      @sp.title = 'test'
      @sp.license = 'all-rights-reserved'
      @sp.save!
      SightingPhoto.do_post_process(@sp.id)
    end

    should "be accessible" do
      assert !@sp.private
      assert !@sp.comment_collection.private
      assert @sp.user == @s.user

      assert @sp.photo.path =~ /public/
      assert File.exist?(@sp.photo.path)
    end

    should "be visible to everyone" do
      assert @sp.publicize!(false)
    end

    context "that has been made private" do
      setup do
        @s.reload
        @s.private = true
        @s.save!
        @sp = SightingPhoto.find(@sp.id)
      end

      should "be accessible" do
        assert @sp.private
        assert @sp.comment_collection.private
        assert @sp.user == @s.user

        assert @sp.photo.path =~ /private/
        assert File.exist?(@sp.photo.path)
      end

      should "be visible to its owner" do
        assert @sp.publicize!(@s.user)
      end

      should "not be visible to everyone" do
        assert_raise RuntimeError do
          @sp.publicize!(false)
        end
      end

      context "that has been made public again" do
        setup do
          @s.reload
          @s.private = false
          @s.save!
          @sp = SightingPhoto.find(@sp.id)
        end

        should "be accessible" do
          assert !@sp.private
          assert !@sp.comment_collection.private
          assert @sp.user == @s.user

          assert @sp.photo.path =~ /public/
          assert File.exist?(@sp.photo.path)
        end
      end
    end
  end

  context "A valid public photo" do
    setup do
      @s = users(:quentin).sightings.first
      @s.private = false
      @s.save!
      @sp = @s.sighting_photo.build
      @sp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      @sp.title = 'test'
      @sp.license = 'all-rights-reserved'
      @sp.save!
      SightingPhoto.do_post_process(@sp.id)
    end

    should "have the same species as its sighting" do
      assert_equal @s.species, @sp.species
    end

    context "whose sighting species was changed" do
      setup do
        @s.species_id = @s.species_id + 1
        assert @s.save
        @sp.reload
        @s.reload
      end

      should "have the same species as its sighting" do
        assert_equal @s.species, @sp.species
      end
    end
  end

  context "A photo" do
    setup do
      @s = users(:quentin).sightings.first
      @s.private = false
      @s.save!
      @sp = @s.sighting_photo.build
      @sp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      @sp.title = 'test'
      @sp.license = 'all-rights-reserved'
      @sp.save!
      SightingPhoto.do_post_process(@sp.id)

      @size = File.stat(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png').size
    end

    should "increment the total number of photos for that user" do
      assert_equal 1, User.find_by_login('quentin').num_photos
    end

    context "and another photo" do
      setup do
        @sp2 = @s.sighting_photo.build
        @sp2.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
        @sp2.title = 'test'
        @sp2.license = 'all-rights-reserved'
        @sp2.save!
        SightingPhoto.do_post_process(@sp2.id)
      end

      should "increment the total number of photos for that user" do
        assert_equal 2, User.find_by_login('quentin').num_photos
      end

      context "that has been deleted" do
        setup do
          SightingPhoto.find(@sp2.id).destroy
        end

        should "decrement the total number of photos for that user" do
          assert_equal 1, User.find_by_login('quentin').num_photos
        end
      end
    end

    context "that has been deleted" do
      setup do
        SightingPhoto.find(@sp.id).destroy
      end

      should "decrement the total number of photos for that user" do
        assert_equal 0, User.find_by_login('quentin').num_photos
      end
    end
  end

  context "A photo that exceeds the total upload limit" do
    setup do
      u = users(:quentin)
      # pretend that the user has uploaded many files
      u.num_photos = u.photo_upload_limit
      assert u.save

      @s = u.sightings.first
    end

    should "fail" do
      sp = @s.sighting_photo.build
      sp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      sp.title = 'test'
      sp.license = 'all-rights-reserved'
      assert !sp.save
      assert sp.errors.on(:file)
    end
  end

  context "A photo that almost exceeds the total upload limit" do
    setup do
      u = users(:quentin)
      # pretend that the user has uploaded many files
      # but not enough to go over the limit
      u.num_photos = u.photo_upload_limit - 1
      assert u.save

      @s = u.sightings.first
    end

    should "succeed" do
      sp = @s.sighting_photo.build
      sp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      sp.title = 'test'
      sp.license = 'all-rights-reserved'
      assert sp.save
      SightingPhoto.do_post_process(sp.id)
      assert sp.reload
    end
  end

  context "A photo without a title" do
    setup do
      s = users(:quentin).sightings.first
      @sp = s.sighting_photo.build
      @sp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      @sp.license = 'all-rights-reserved'
    end

    should "have errors on save" do
      assert !@sp.save
      assert @sp.errors.on(:title)
    end
  end

  context "A valid public photo" do
    setup do
      @s = users(:quentin).sightings.first
      @s.private = false
      @s.trip = users(:quentin).trips.first
      @s.save!
      @sp = @s.sighting_photo.build
      @sp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      @sp.title = 'test'
      @sp.license = 'all-rights-reserved'
      @sp.save!
      SightingPhoto.do_post_process(@sp.id)
    end

    should "have the same trip as its sighting" do
      assert_equal @s.trip, @sp.trip
    end

    context "whose trip was changed" do
      setup do
        @s.trip = Trip.find(3)
        assert @s.save
        @sp.reload
        @s.reload
      end

      should "have the same trip as its sighting" do
        assert_equal @s.trip, @sp.trip
      end
    end
  end

  context "A valid public photo" do
    setup do
      @s = users(:quentin).sightings.first
      @s.private = false
      @s.user_location = users(:quentin).user_locations.all[0]
      @s.save!
      @sp = @s.sighting_photo.build
      @sp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      @sp.title = 'test'
      @sp.license = 'all-rights-reserved'
      @sp.save!
      SightingPhoto.do_post_process(@sp.id)
    end

    should "have the same location as its sighting" do
      assert_equal @s.user_location, @sp.user_location
    end

    context "whose location was erased" do
      setup do
        @s.user_location = nil
        assert @s.save
        @sp.reload
        @s.reload
      end

      should "have the same location as its sighting" do
        assert_equal @s.user_location, @sp.user_location
      end
    end
  end
end
