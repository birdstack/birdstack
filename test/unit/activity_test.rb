require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < ActiveSupport::TestCase
  context "A current activity feed plus a new private sighting" do
    setup do
      # Generate activities for all existing sightings
      Birdstack::Background::ActivityGenerator.generate_activities

      # Hack to make sure the occurred_at time is really old for the activity that this generated
      Activity.find(:all).each do |a|
        a.occurred_at = Time.now - (Birdstack::Background::ActivityGenerator::MAX_TIME_SPAN * 3)
        a.save!
      end

      @s = Sighting.new
      @s.species = species(:american_robin)
      @s.user = users(:quentin)
      @s.private = 1
      assert @s.save
    end

    should "not generate any activity" do
      assert_no_difference users(:quentin).activities, :count do
        Birdstack::Background::ActivityGenerator.generate_activities
      end
      @s.reload
      assert_nil @s.sighting_activity
    end
  end

  context "A current activity feed plus a new sighting with location and trip in the feed" do
    setup do
      # Generate activities for all existing sightings
      Birdstack::Background::ActivityGenerator.generate_activities

      # Hack to make sure the occurred_at time is really old for the activity that this generated
      Activity.find(:all).each do |a|
        a.occurred_at = Time.now - (Birdstack::Background::ActivityGenerator::MAX_TIME_SPAN * 3)
        a.save!
      end

      @s = Sighting.new
      @s.species = species(:american_robin)
      @s.user_location = user_locations(:ebirdablelocation)
      @s.trip = trips(:awesometrip)
      @s.user = users(:quentin)
      assert @s.save
      assert_difference users(:quentin).activities, :count, 1 do
        Birdstack::Background::ActivityGenerator.generate_activities
      end
      @s.reload
      assert_equal @s.sighting_activity, users(:quentin).activities.find(:first, :order => 'occurred_at DESC')
    end

    should "disappear when marked private" do
      @s.private = 1

      assert_difference users(:quentin).activities, :count, -1 do
        @s.save
      end
      @s.reload
      assert_nil @s.sighting_activity
    end

    should "disappear when their trip is marked private" do
      t = @s.trip
      t.private = 1

      # -2 because one of the fixtures also uses that trip
      assert_difference users(:quentin).activities, :count, -2 do
        assert t.save
      end
      @s.reload
      assert_nil @s.sighting_activity
    end

    should "disappear when their location is marked private" do
      l = @s.user_location
      l.private = 1

      # -2 because one of the fixtures also uses that location
      assert_difference users(:quentin).activities, :count, -2 do
        assert l.save
      end
      @s.reload
      assert_nil @s.sighting_activity
    end
  end

  context "A current activity feed plus a new sighting" do
    setup do
      # Generate activities for all existing sightings
      Birdstack::Background::ActivityGenerator.generate_activities

      # Hack to make sure the occurred_at time is really old for the activity that this generated
      Activity.find(:all).each do |a|
        a.occurred_at = Time.now - (Birdstack::Background::ActivityGenerator::MAX_TIME_SPAN * 3)
        a.save!
      end

      @s = Sighting.new
      @s.species = species(:american_robin)
      @s.user = users(:quentin)
      assert @s.save
    end

    should "create an activity and associate the sighting" do
      assert_difference users(:quentin).activities, :count, 1 do
        Birdstack::Background::ActivityGenerator.generate_activities
      end
      @s.reload
      assert_equal @s.sighting_activity, users(:quentin).activities.find(:first, :order => 'occurred_at DESC')
      assert_equal 1, @s.sighting_activity.description[:num_sightings]
    end
    
    context "plus another new sighting" do
      setup do
        @s2 = Sighting.new
        @s2.species = species(:american_robin)
        @s2.user = users(:quentin)
        assert @s2.save
      end

      should "still create only 1 activity" do
        assert_difference users(:quentin).activities, :count, 1 do
          Birdstack::Background::ActivityGenerator.generate_activities
        end
        @s.reload
        @s2.reload
        assert @s.sighting_activity
        assert @s2.sighting_activity
        assert_equal @s.sighting_activity, @s2.sighting_activity

        assert_equal 2, @s.sighting_activity.description[:num_sightings]
      end
    end

    context "plus another new sighting separated by an hour" do
      setup do
        @s2 = Sighting.new
        @s2.species = species(:american_robin)
        @s2.user = users(:quentin)
        @s2.created_at = @s.created_at - Birdstack::Background::ActivityGenerator::MAX_TIME_SPAN - 1.minute
        assert @s2.save
      end

      should "create 2 activities" do
        assert_difference users(:quentin).activities, :count, 2 do
          Birdstack::Background::ActivityGenerator.generate_activities
        end
        @s.reload
        @s2.reload
        assert @s.sighting_activity
        assert @s2.sighting_activity
        assert_not_equal @s.sighting_activity, @s2.sighting_activity
      end
    end

    context "that has been put into an activity" do
      setup do
        Birdstack::Background::ActivityGenerator.generate_activities
      end

      should "include a new sighting within the correct timeframe into the existing activity" do
        @s = Sighting.new
        @s.species = species(:american_robin)
        @s.user = users(:quentin)
        assert @s.save

        assert_difference users(:quentin).activities, :count, 0 do
          Birdstack::Background::ActivityGenerator.generate_activities
        end
        @s.reload
        assert_equal 2, @s.sighting_activity.description[:num_sightings]
      end
    end
  end

  context "A current activity feed plus a new sighting photo" do
    setup do
      # Generate activities for all existing sightings
      Birdstack::Background::ActivityGenerator.generate_activities

      # Hack to make sure the occurred_at time is really old for the activity that this generated
      Activity.find(:all).each do |a|
        a.occurred_at = Time.now - (Birdstack::Background::ActivityGenerator::MAX_TIME_SPAN * 3)
        a.save!
      end

      @s = users(:quentin).sightings.first
      @sp = @s.sighting_photo.build
      @sp.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
      @sp.title = 'test'
      @sp.license = 'all-rights-reserved'
      @sp.save!
      SightingPhoto.do_post_process(@sp.id)
      @sp.reload
    end

    should "create an activity and associate the sighting photo" do
      assert_difference users(:quentin).activities, :count, 1 do
        Birdstack::Background::ActivityGenerator.generate_activities
      end
      @sp.reload
      assert_equal @sp.sighting_photo_activity, users(:quentin).activities.find(:first, :order => 'occurred_at DESC')
      assert_equal 1, @sp.sighting_photo_activity.description[:num_photos]
    end
    
    context "plus another new sighting photo" do
      setup do
        @sp2 = @s.sighting_photo.build
        @sp2.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
        @sp2.title = 'test'
        @sp2.license = 'all-rights-reserved'
        @sp2.save!
        SightingPhoto.do_post_process(@sp2.id)
        @sp2.reload
      end

      should "still create only 1 activity" do
        assert_difference users(:quentin).activities, :count, 1 do
          Birdstack::Background::ActivityGenerator.generate_activities
        end
        @sp.reload
        @sp2.reload
        assert @sp.sighting_photo_activity
        assert @sp2.sighting_photo_activity
        assert_equal @sp.sighting_photo_activity, @sp2.sighting_photo_activity

        assert_equal 2, @sp.sighting_photo_activity.description[:num_photos]
      end
    end

    context "that has been put into an activity" do
      setup do
        Birdstack::Background::ActivityGenerator.generate_activities
      end

      should "include a new sighting within the correct timeframe into the existing activity" do
        @sp2 = @s.sighting_photo.build
        @sp2.photo = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
        @sp2.title = 'test'
        @sp2.license = 'all-rights-reserved'
        @sp2.save!
        SightingPhoto.do_post_process(@sp2.id)
        @sp2.reload

        assert_difference users(:quentin).activities, :count, 0 do
          Birdstack::Background::ActivityGenerator.generate_activities
        end

        @sp.reload
        @sp2.reload
        assert @sp.sighting_photo_activity
        assert @sp2.sighting_photo_activity
        assert_equal @sp.sighting_photo_activity, @sp2.sighting_photo_activity

        assert_equal 2, @sp.sighting_photo_activity.description[:num_photos]
      end
    end
  end

  context "An activity" do
    setup do
      @a = Activity.new
      @a.occurred_at = Time.now
      @a.user = users(:quentin)
    end

    should "serialize data" do
      @a.description['test'] = 'llama'
      assert @a.save

      @a = Activity.find(@a.id)
      assert_equal 'llama', @a.description['test']
      assert @a.save
    end
  end
end
