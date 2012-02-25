require File.dirname(__FILE__) + '/../test_helper'

class SearchManagerTest < ActiveSupport::TestCase
	def test_two_select_hash
		params = {
			:observation_location_location => {
				:id => [
					'Hutchinson,Reno County,KS,US',
					'Wichita,Sedgwick County,KS,US',
				]
			},
		}

		sanitized_hash = {
			:observation_location_location => [
				{
					:location	=> 'Hutchinson',
					:adm2		=> 'Reno County',
					:adm1		=> 'KS',
					:cc		=> 'US',
				},
				{
					:location	=> 'Wichita',
					:adm2		=> 'Sedgwick County',
					:adm1		=> 'KS',
					:cc		=> 'US',
				}
			]
		}

		assert_equal(sanitized_hash, Birdstack::Search::sanitize_hash(params))	

		search = Birdstack::Search.new(nil, params, false, nil)
		search.generate_instance_vars(self)

		assert_equal params[:observation_location_location][:id], @observation_location_location

		assert_equal({:joins=>["LEFT OUTER JOIN user_locations ON user_locations.id = sightings.user_location_id"], :conditions=>["((user_locations.location = ? AND user_locations.adm2 = ? AND user_locations.adm1 = ? AND user_locations.cc = ?) OR (user_locations.location = ? AND user_locations.adm2 = ? AND user_locations.adm1 = ? AND user_locations.cc = ?))", "Hutchinson", "Reno County", "KS", "US", "Wichita", "Sedgwick County", "KS", "US"]}, search.search_params)
	end

	def test_normal_hash
		params = {
			:observation_time => {
				:hour_start	=> '1',
				:minute_start	=> '2',
				:hour_end	=> '3',
				:minute_end	=> '4',
			},
		}

		sanitized_hash = {
			:observation_time => {
				:hour_start	=> 1,
				:minute_start	=> 2,
				:hour_end	=> 3,
				:minute_end	=> 4,
			},
		}

		assert_equal(sanitized_hash, Birdstack::Search.sanitize_hash(params))	

		search = Birdstack::Search.new(nil, params, false, nil)
		search.generate_instance_vars(self)

		assert_equal 1, @observation_time.hour_start
		assert_equal 2, @observation_time.minute_start
		assert_equal 3, @observation_time.hour_end
		assert_equal 4, @observation_time.minute_end

		# This is actually incorrect, but it's the expected behavior for now
		assert_equal({:joins => [], :conditions=>["((sightings.time_hour = ? AND sightings.time_minute = ? AND sightings.time_hour = ? AND sightings.time_minute = ?))", 1, 2, 3, 4]}, search.search_params)
	end

	def test_find_with_blank_adm1
		params = {
			:observation_location_adm2 => {
				:id	=> 'Reno County,,US',
			}
		}

		search = Birdstack::Search.new(nil, params, false, nil)
		results = search.search

		assert results.include?(sightings(:noadm1))
		assert results.include?(sightings(:blankadm1))
	end

	def test_dont_find_private_sighting
		params = {
			:observation_time => {
				:hour_start	=> 1,
				:minute_start	=> 41,
				:hour_end	=> 1,
				:minute_end	=> 41,
			}
		}

		# Search with the search owned by user 1 and run by user 1
		search = Birdstack::Search.new(users(:quentin), params, false, users(:quentin))
		results = search.search

		assert_equal 1, results.size

		# Search with the search owned by user 1 and run by nobody
		search = Birdstack::Search.new(users(:quentin), params, false, :false)
		results = search.search

		assert_equal 0, results.size
	end

	def test_no_duplicate_results_on_multiple_tag_matches
		params = {
			:observation_tag => {
				:id => ['cheese', 'llama'],
			}
		}

		# Make sighting with those tags
		sighting = users(:quentin).sightings.find(:first)
		sighting.tag_list = 'cheese,llama'
		sighting.save!

		# Search with the search owned by user 1 and run by user 1
		search = Birdstack::Search.new(users(:quentin), params, false, users(:quentin))
		results = search.search

		# We should have only 1 result
		assert_equal 1, results.size

		# Do it again for life list
		params.merge!(:observation_search_type => {:type => 'earliest'})

		# Search with the search owned by user 1 and run by user 1
		search = Birdstack::Search.new(users(:quentin), params, false, users(:quentin))
		results = search.search

		# We should have only 1 result
		assert_equal 1, results.size
	end

	def test_search_by_private_criteria
		sighting = users(:quentin).sightings.find(:first)

		loc = UserLocation.create(:name => 'test search privacy', :private => 2)
		loc.user = users(:quentin)
		loc.save!

		trip = Trip.new(:name => 'test search blah blah blah', :private => 1)
		trip.user = users(:quentin)
		trip.save!

		params = {
			:observation_location_name => {
				:id => [
					loc.id.to_s,
				]
			},
		}

		sighting.user_location = loc
		sighting.trip = trip
		sighting.save!

		# Search with the search owned by user 1 and run by user 1
		search = Birdstack::Search.new(users(:quentin), params, false, users(:quentin))
		results = search.search

		# We should have only 1 result
		assert_equal 1, results.size
		
		# Search with the search owned by user 1 and run by someone else
		search = Birdstack::Search.new(users(:quentin), params, false, nil)
		results = search.search

		# We should have no results because even though the sighting was public,
		# the criteria used to find it was not
		assert_equal 0, results.size
		
		# Now, just to make sure, make the location public and run the search publicly again
		loc.private = 0
		loc.save!

		# Search with the search owned by user 1 and run by someone else
		search = Birdstack::Search.new(users(:quentin), params, false, nil)
		results = search.search

		# We should have no results because even though the sighting was public,
		# the criteria used to find it was not
		assert_equal 1, results.size

		# Back to fully private for these next tests
		loc.private = 2
		loc.save!

		# Test for trips
		params = {
			:observation_trip => {
				:id => [
					trip.id.to_s,
				]
			},
		}
			
		# Search with the search owned by user 1 and run by user 1
		search = Birdstack::Search.new(users(:quentin), params, false, users(:quentin))
		results = search.search

		# We should have only 1 result
		assert_equal 1, results.size
		
		# Search with the search owned by user 1 and run by someone else
		search = Birdstack::Search.new(users(:quentin), params, false, nil)
		results = search.search

		# We should have no results because even though the sighting was public,
		# the criteria used to find it was not
		assert_equal 0, results.size

		# If we search for just observations of a particular species, it should be in the public list
		params = {
			:observation_species => {
				:id => [
					sighting.species.id
				]
			},
		}

		# Search with the search owned by user 1 and run by someone else
		search = Birdstack::Search.new(users(:quentin), params, false, nil)
		results = search.search

		# We should have no results because even though the sighting was public,
		# the criteria used to find it was not
		assert results.include?(sighting)
		
		# But, if we search for that species from the private location, it should not be in the public list
		params = {
			:observation_species => {
				:id => [
					sighting.species.id
				]
			},
			:observation_location_name => {
				:id => [
					loc.id.to_s,
				]
			},
		}

		# Search with the search owned by user 1 and run by someone else
		search = Birdstack::Search.new(users(:quentin), params, false, nil)
		results = search.search

		# We should have no results because even though the sighting was public,
		# the criteria used to find it was not
		assert !results.include?(sighting)
	end

	# Make sure AR doesn't use the ID column from a different table when a sort requires a JOIN on one of the special kinds of queries
	# See the search manager source for more details
	def test_ar_confusion_on_joined_tables
		params = {
			:observation_time => {
				:hour_start	=> 1,
				:minute_start	=> 42,
				:hour_end	=> 1,
				:minute_end	=> 42,
			},
			:observation_search_type => {
				:type	=> 'earliest',
			},
			:observation_search_display => {
				:sort	=> 'species_english_asc',
			},
		}

		search = Birdstack::Search.new(users(:joe), params, false, users(:joe))
		results = search.search

		assert_equal 1, results.size

		assert_equal sightings(:gettheidright).id, results[0].id
	end

	def test_join_problems
		# On searches that weren't 'earliest' or 'latest', I had a problem with the joins in the outer
		# query referencing tables that were only joined in the subquery
		# This test should trigger that problem by doing a sort on a table that has to be joined (species)
		# and not using an 'earliest' or 'latest' search
		params = {
			:observation_time => {
				:hour_start	=> 1,
				:minute_start	=> 42,
				:hour_end	=> 1,
				:minute_end	=> 42,
			},
			:observation_search_display => {
				:sort	=> 'species_english_asc',
			},
		}

		search = Birdstack::Search.new(users(:joe), params, false, users(:joe))
		results = search.search

		assert_equal 1, results.size

		assert_equal sightings(:gettheidright).id, results[0].id
	end
end
