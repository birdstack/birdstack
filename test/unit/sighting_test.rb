require File.dirname(__FILE__) + '/../test_helper'

class SightingTest < ActiveSupport::TestCase
	def test_blank_link_accepted
		assert_difference Sighting, :count do
			assert create_sighting(:link => '')
		end
	end

	def test_create_minimal_sighting
		assert_difference Sighting, :count do
			assert_equal [], create_sighting.errors.full_messages
		end
	end

	def test_sighting_comments
		s = create_sighting
		assert_equal 0, s.comment_collection.comments.size
		s.destroy
		assert !CommentCollection.find_by_id(s.comment_collection.id)
	end

	def test_year_required_with_month
		assert_no_difference Sighting, :count do
			assert create_sighting(:date_month => 1).errors.on(:date_year)
		end
	end

	def test_valid_year
		assert_no_difference Sighting, :count do
			assert create_sighting(:date_year => 1899).errors.on(:date_year)
		end

		assert_no_difference Sighting, :count do
			assert create_sighting(:date_year => Time.now.year + 2).errors.on(:date_year)
		end

		assert_difference Sighting, :count do
			assert !create_sighting(:date_year => 1950).errors.on(:date_year)
		end
	end

	def test_month_required_with_day
		assert_no_difference Sighting, :count do
			assert create_sighting(:date_day => 1).errors.on(:date_month)
		end
	end

	def test_valid_date
		assert_no_difference Sighting, :count do
			assert create_sighting(:date_day => 31, :date_month => 2, :date_year => 2000).errors.on(:date)
		end
	end

	def test_non_future_date
		assert_no_difference Sighting, :count do
			future = Date.tomorrow + 1.day
			assert create_sighting(:date_day => future.day, :date_month => future.month, :date_year => future.year).errors.on(:date)
		end
	end

	def test_valid_leap_date
		assert_difference Sighting, :count do
			assert !create_sighting(:date_day => 29, :date_month => 2, :date_year => 2004).errors.on(:date)
		end

		assert_no_difference Sighting, :count do
			assert create_sighting(:date_day => 29, :date_month => 2, :date_year => 2005).errors.on(:date)
		end
	end

	def test_species_count_infer
		assert_difference Sighting, :count do
			assert sighting = create_sighting(:adult_male => 1)
			assert_equal 1, sighting.species_count
		end
	end

	def test_unknown_count_infer
		assert_difference Sighting, :count do
			assert sighting = create_sighting(:species_count => 2, :adult_male => 1)
			assert_equal 1, sighting.unknown_unknown
		end
	end

	def test_count_discrepancy
		assert_no_difference Sighting, :count do
			assert create_sighting(:species_count => 2, :adult_male => 41).errors.on(:species_count)
		end
	end

	def test_no_negative_count
		assert_no_difference Sighting, :count do
			sighting = create_sighting(:species_count => 2, :adult_male => 1, :adult_female => -1)
			assert sighting.errors.on(:age_sex)
		end
		assert_no_difference Sighting, :count do
			sighting = create_sighting(:species_count => -2, :adult_male => 1, :adult_female => 1)
			assert sighting.errors.on(:species_count)
		end
	end

	def test_hour_required
		assert_no_difference Sighting, :count do
			assert create_sighting(:time_minute => '0').errors.on(:time_hour)
		end
	end

	def test_minute_filled_in
		assert_difference Sighting, :count do
			assert sighting = create_sighting(:time_hour => '1')
			assert_equal 0, sighting.time_minute
		end
	end

	def test_publicize
		sighting = create_sighting(:private => 1, :user => users(:quentin))
		assert_raise RuntimeError do
			sighting.publicize!
		end

		# And make sure we allow ourselves to view it
		sighting = create_sighting(:private => 1, :user => users(:quentin))
		assert_nothing_raised do
			sighting.publicize!(users(:quentin))
		end

		assert sighting.frozen?
		assert sighting.readonly?

		# We can publicize it twice
		assert_nothing_raised do
		      sighting.publicize!(users(:quentin))
		end

		# But not for a different user
		assert_raise RuntimeError do
		      sighting.publicize!
		end
	end

	def test_private_location
		# First, test that non-private data gets through
		sighting = create_sighting(:user => users(:quentin))
		sighting.user_location = UserLocation.create({:name => 'cheese', :user => users(:quentin), :private => 0})
		sighting.publicize!

		assert_equal 'cheese', sighting.user_location.name

		# Then that private data doesn't
		sighting = create_sighting(:user => users(:quentin))
		sighting.user_location = UserLocation.create({:name => 'cheese', :user => users(:quentin), :private => 2})
		sighting.publicize!

		assert_nil sighting.user_location
		
		# Then that private data doesn't (even for coordinates without publicize!ing it myself)
		sighting = create_sighting(:user => users(:quentin))
		sighting.user_location = UserLocation.create({:name => 'cheese', :private => 1, :latitude => 41})
		sighting.user_location.user = users(:quentin)
		sighting.publicize!

		assert_nil sighting.user_location.latitude
		
		# Then that private data doesn't (even for coordinates without publicize!ing it myself) -- unless I own it
		sighting = create_sighting(:user => users(:quentin))
		sighting.user_location = UserLocation.create({:name => 'cheese', :private => 1, :latitude => 41})
		sighting.user_location.user = users(:quentin)
		sighting.publicize!(users(:quentin))

		assert_equal 41, sighting.user_location.latitude

		# And that the right user carried through
		assert_nothing_raised do
			sighting.user_location.publicize!(users(:quentin))
		end

		assert_raise RuntimeError do
			sighting.user_location.publicize!
		end
	end

	def test_private_trip
		# First, test that non-private data gets through
		sighting = create_sighting(:user => users(:quentin))
		sighting.trip = Trip.new({:name => 'cheese', :user => users(:quentin)})
		sighting.publicize!

		assert_equal 'cheese', sighting.trip.name

		# Then that private data doesn't
		sighting = create_sighting(:user => users(:quentin))
		sighting.trip = Trip.new({:name => 'cheese', :user => users(:quentin), :private => true})
		sighting.publicize!

		assert_nil sighting.trip
	end

	def test_no_letters_in_counts
		sighting = create_sighting(:user => users(:quentin), :juvenile_female => 'a')
		assert sighting.errors.on(:age_sex)
		# Make sure we didn't typecast 'a' to 0 and then add up the 0s to put a 0 in species_count
		assert_nil sighting.species_count
	end

        def test_lock_on_save
          sighting = create_sighting(:user => users(:quentin))
          s2 = Sighting.find(sighting.id)
          s2.private = true
          s2.save
          sighting.private = true
          assert_raises(ActiveRecord::StaleObjectError) { sighting.save }
        end

        # If this test fails, it means my patch hasn't been accepted yet.  You'll need to manually apply it:
        # http://rails.lighthouseapp.com/projects/8994/tickets/1966-patch-destroy-should-respect-optimistic-locking
        def test_lock_on_destroy
          sighting = create_sighting(:user => users(:quentin))
          s2 = Sighting.find(sighting.id)
          s2.private = true
          s2.save
          assert_raises(ActiveRecord::StaleObjectError) { sighting.destroy }
        end

	private

	def create_sighting(options = {})
		sighting = Sighting.new({ :species_id => 1 }.merge(options))
		sighting.user_id = 1
		sighting.save
		sighting
	end
end
