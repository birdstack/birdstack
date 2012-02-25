require File.dirname(__FILE__) + '/../test_helper'

class TripTest < ActiveSupport::TestCase
	def test_no_science_trip_parent
		trip = Trip.new(:name => 'test')
		trip.user = users(:quentin)
		assert trip.save
		trip.move_to_child_of(trips(:awesometrip).id)
		assert trip.save
		trip.move_to_child_of(trips(:carefultrip).id)
		assert !trip.save
	end

	def test_create_minimal_science_trip
		assert_difference Trip, :count do
			assert_equal [], create_science_trip.errors.full_messages
		end
	end

	def test_trip_comments
		t = create_science_trip
		assert_equal 0, t.comment_collection.comments.size
		t.destroy
		assert !CommentCollection.find_by_id(t.comment_collection.id)
	end

	def test_year_required
		assert_no_difference Trip, :count do
			assert create_science_trip(:date_year_start => nil).errors.on(:date_year_start)
		end
	end

	def test_month_required
		assert_no_difference Trip, :count do
			assert create_science_trip(:date_month_start => nil).errors.on(:date_month_start)
		end
	end

	def test_day_required
		assert_no_difference Trip, :count do
			assert create_science_trip(:date_day_start => nil).errors.on(:date_day_start)
		end
	end

	def test_valid_year
		assert_no_difference Trip, :count do
			assert create_science_trip(:date_year_start => 1899).errors.on(:date_year_start)
		end

		# It's okay to be in the future for trips

		assert_difference Trip, :count do
			assert !create_science_trip(:date_year_start => 1950).errors.on(:date_year_start)
		end
	end

	def test_valid_date
		assert_no_difference Trip, :count do
			assert create_science_trip(:date_day_start => 31, :date_month_start => 2, :date_year_start => 2000).errors.on(:date_start)
		end
	end

	def test_valid_leap_date
		assert_difference Trip, :count do
			assert !create_science_trip(:date_day_start => 29, :date_month_start => 2, :date_year_start => 2004, :date_year_end => 2005).errors.on(:date_start)
		end

		assert_no_difference Trip, :count do
			assert create_science_trip(:date_day_start => 29, :date_month_start => 2, :date_year_start => 2005).errors.on(:date_start)
		end
	end

	def test_distance_conversion
		sciencetrip = nil
		assert_difference Trip, :count do
			assert sciencetrip = create_science_trip(:protocol => 'traveling', :distance_traveled => '1', :distance_traveled_units => 'km')
			sciencetrip.reload # let MySQL round it out
			assert_equal '0.621371', sciencetrip.distance_traveled_mi.to_s
		end
		sciencetrip.destroy

		assert_difference Trip, :count do
			assert sciencetrip = create_science_trip(:protocol => 'traveling', :distance_traveled => '1', :distance_traveled_units => 'mi')
			sciencetrip.reload # let MySQL round it out
			assert_equal '1.60934', sciencetrip.distance_traveled_km.to_s
		end
		sciencetrip.destroy
	end

	def test_area_conversion
		sciencetrip = nil
		assert_difference Trip, :count do
			assert sciencetrip = create_science_trip(:protocol => 'area', :area_covered => '1', :area_covered_units => 'sqkm')
			sciencetrip.reload # let MySQL round it out
			assert_equal '0.386102', sciencetrip.area_covered_sqmi.to_s
			assert_equal '247.105', sciencetrip.area_covered_acres.to_s
		end
		sciencetrip.destroy

		assert_difference Trip, :count do
			assert sciencetrip = create_science_trip(:protocol => 'area', :area_covered => '100', :area_covered_units => 'ha')
			sciencetrip.reload # let MySQL round it out
			assert_equal '0.386102', sciencetrip.area_covered_sqmi.to_s
			assert_equal '247.105', sciencetrip.area_covered_acres.to_s
		end
		sciencetrip.destroy

		assert_difference Trip, :count do
			assert sciencetrip = create_science_trip(:protocol => 'area', :area_covered => '1', :area_covered_units => 'sqmi')
			sciencetrip.reload # let MySQL round it out
			assert_equal '2.58999', sciencetrip.area_covered_sqkm.to_s
			assert_equal '640.0', sciencetrip.area_covered_acres.to_s
		end
		sciencetrip.destroy

		assert_difference Trip, :count do
			assert sciencetrip = create_science_trip(:protocol => 'area', :area_covered => '1', :area_covered_units => 'acres')
			sciencetrip.reload # let MySQL round it out
			assert_equal '0.0015625', sciencetrip.area_covered_sqmi.to_s
			assert_equal '0.00404686', sciencetrip.area_covered_sqkm.to_s
		end
		sciencetrip.destroy
	end

	def test_sighting_date_match
		# Try it without matching the dates up (the fixture leaves the date blank on the sighting)
		assert_no_difference Trip, :count do
			sctrip = trips(:carefultrip)
			sctrip.save
			assert sctrip.errors[:sightings]
		end

		# Now match up the dates, it should work
		assert_no_difference Trip, :count do
			sctrip = trips(:carefultrip)

			sighting = sightings(:carefultripbird)
			sighting.date_year = sctrip.date_year_start
			sighting.date_month = sctrip.date_month_start
			sighting.date_day = sctrip.date_day_start

			assert sighting.save

			# Need to reload the science trip now that we've updated the sighting
			sctrip.reload

			assert sctrip.save
		end
	end

	def test_funky_validation
		assert_no_difference Trip, :count do
			sctrip = trips(:correcttrip)
			assert sctrip.save
			sctrip = trips(:correcttrip)
			sctrip.date_day_start = 1
			assert !sctrip.save
		end
	end

	def test_day_spanning_trip
		assert_no_difference Trip, :count do
			sctrip = trips(:dayspantrip)
			assert sctrip.save
		end
	end

	def test_non_science_trip_with_sighting_out_of_range
		assert_no_difference Trip, :count do
			sctrip = trips(:nonsciencetripwithsightingoutsiderange)
			assert !sctrip.save
		end
	end

	def test_non_science_trip_with_sighting_without_date
		assert_no_difference Trip, :count do
			sctrip = trips(:nonsciencetripwithsightingnodate)
			assert sctrip.save
		end
	end

	def test_publicize
		trip = create_science_trip(:private => 1, :user => users(:quentin))
		assert_raise RuntimeError do
			trip.publicize!
		end

		# And make sure we allow ourselves to view it
		trip = create_science_trip(:private => 1, :user => users(:quentin))
		assert_nothing_raised do
			trip.publicize!(users(:quentin))
		end

		assert trip.frozen?
		assert trip.readonly?

		# We can publicize it twice
		assert_nothing_raised do
			trip.publicize!(users(:quentin))
		end

		# But not for a different user
		assert_raise RuntimeError do
			trip.publicize!
		end
	end

        # Ensure that find_public_by_user publicizes for whom we think it will
        def test_republicize
          trips = Trip.find_public_by_user(users(:quentin))
          trips.each do |t|
            assert t.publicize!
          end
        end

        def test_create_bad_date
          trip = create_science_trip
          # Time.gm won't like this, so it shouldn't be allowed
          trip.date_year_start = 199900000000000
          assert !trip.save
        end

	private

	def create_science_trip(options = {})
		trip = Trip.new({ :name => 'test trip', :date_year_start => 1985, :date_month_start => 3, :date_day_start => 3, :date_year_end => 1985, :date_month_end => 3, :date_day_end => 3, :time_hour_start => 1, :time_minute_start => 1, :protocol => 'stationary', :duration_hours => 1, :duration_minutes => 1 }.merge(options))
		trip.user_id = users(:quentin).id
		trip.save
		trip
	end
end
