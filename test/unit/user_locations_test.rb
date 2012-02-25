require File.dirname(__FILE__) + '/../test_helper'

class UserLocationsTest < ActiveSupport::TestCase
	def test_location_comments
		l = UserLocation.create(:name => 'test123')
		l.user = users(:quentin)
		assert l.save

		assert_equal 0, l.comment_collection.comments.size
		l.destroy
		assert !CommentCollection.find_by_id(l.comment_collection.id)
	end

	def test_invalid_ecoregion
		assert_no_difference UserLocation, :count do
			assert UserLocation.create(:name => 'test', :ecoregion => 'LL1234').errors.on(:ecoregion)
		end

		assert_no_difference UserLocation, :count do
			assert UserLocation.create(:name => 'test', :ecoregion => 'AA12345').errors.on(:ecoregion)
		end
	end

	def test_valid_ecoregion
		assert_difference UserLocation, :count do
			location = UserLocation.create(:name => 'testgoodecoregion', :ecoregion => 'AA0101')
			location.user = users(:quentin)
			assert location.save
		end
	end

	def test_elevation_conversion
		assert_difference UserLocation, :count do
			location = UserLocation.create(:name => 'testmtoft', :elevation_m => '1')
			location.user = users(:quentin)
			assert location.save
			assert_equal '3.28083989501312', location.elevation_ft.to_s
		end

		assert_difference UserLocation, :count do
			location = UserLocation.create(:name => 'testfttom', :elevation_ft => '1')
			location.user = users(:quentin)
			assert location.save
			assert_equal 0.3048, location.elevation_m
		end

		assert_no_difference UserLocation, :count do
			assert UserLocation.create(:elevation_m => 'monkeys!').errors.on(:elevation_m)
		end
	end

	def test_add_with_name
		location = UserLocation.create(:name => 'test', :user => users(:quentin))
		assert_equal 'test', location.name
	end

	def test_add_with_no_name_but_location
		location = UserLocation.create(:location => 'test', :user => users(:quentin))
		assert_equal 'test', location.name
	end
	
	def test_add_with_no_name_but_adm1
		location = UserLocation.create(:adm1 => 'test', :user => users(:quentin))
		assert_equal 'test', location.name
	end

	def test_add_with_no_name_but_adm2
		location = UserLocation.create(:adm2 => 'test', :user => users(:quentin))
		assert_equal 'test', location.name
	end

	def test_add_with_no_name_but_cc
		location = UserLocation.create(:cc => 'US', :user => users(:quentin))
		assert_equal 'United States', location.name
	end

	def test_add_with_no_name_but_invalid_cc
		location = UserLocation.create(:cc => 'ZZ', :user => users(:quentin))
		assert_equal 'ZZ', location.name
	end

	def test_add_with_no_name
		location = UserLocation.create(:user => users(:quentin))
		assert location.errors.on(:name)
	end

	def test_publicize
		location = UserLocation.create(:private => 2)
		location.user = users(:quentin)
		assert_raise RuntimeError do
			location.publicize!
		end

		# And make sure we allow ourselves to view it
		location = UserLocation.create(:private => 2)
		location.user = users(:quentin)
		assert_nothing_raised do
			location.publicize!(users(:quentin))
		end

		assert location.frozen?
		assert location.readonly?

		# We can publicize it twice
		assert_nothing_raised do
			location.publicize!(users(:quentin))
		end
		
		# But not for a different user
		assert_raise RuntimeError do
			location.publicize!
		end
	end
        
        # Ensure that find_public_by_user publicizes for whom we think it will
        def test_republicize
          locations = UserLocation.find_public_by_user(users(:quentin))
          locations.each do |l|
            assert l.publicize!
          end
        end

	def test_user_not_mass_assigned
		location = UserLocation.create(:user => users(:quentin), :user_id => 1)
		assert_nil location.user
		assert_nil location.user_id
	end

	def test_private_coords
		location = UserLocation.create(:private => 1, :latitude => 41, :longitude => 42, :zoom => 7, :source => 'gmap')
		location.user = users(:quentin)

		assert_equal 41, location.latitude
		assert_equal 42, location.longitude
		assert_equal 7, location.zoom
		assert_equal 'gmap', location.source

		location.publicize!

		assert_nil location.latitude
		assert_nil location.longitude
		assert_nil location.zoom
		assert_nil location.source
		assert_nil location.private

		location = UserLocation.create(:private => 1, :latitude => 41, :longitude => 42, :zoom => 7, :source => 'gmap')
		location.user = users(:quentin)
		location.publicize!(users(:quentin))

		assert_equal 41, location.latitude
		assert_equal 42, location.longitude
		assert_equal 7, location.zoom
		assert_equal 'gmap', location.source
	end

	def test_private_coords_comment_collection
		location = UserLocation.create(:name => 'test',:private => 1, :latitude => 41, :longitude => 42, :zoom => 7, :source => 'gmap')
		location.user = users(:quentin)

		location.save

		location.publicize!

		assert location.comment_collection
		assert_equal false, location.comment_collection.private
	end

	def test_merge
		loc1 = UserLocation.create(:name => 'test1')
		loc1.user = users(:quentin)
		loc1.save!

		s1 = Sighting.new({ :species_id => 1 })
		s1.user = users(:quentin)
		s1.user_location = loc1
		s1.save!

		loc2 = UserLocation.create(:name => 'test2')
		loc2.user = users(:quentin)
		loc2.save!

		s2 = Sighting.new({ :species_id => 1 })
		s2.user = users(:quentin)
		s2.user_location = loc2
		s2.save!

		loc3 = UserLocation.create(:name => 'test3')
		loc3.user = users(:joe)
		loc3.save!

		# No merging into someone else's location
		assert !loc2.merge_into(loc3)
		assert !loc3.merge_into(loc2)

		# No merging into the same location
		assert !loc2.merge_into(loc2)

		# Make sure we can merge
		assert loc2.merge_into(loc1)
		assert loc2.frozen?
		assert_equal 0, loc2.sightings.size

		# Make sure the sighting made it across
		s2.reload
		assert_equal loc1, s2.user_location
		# And nothing weird happened to the original
		s1.reload
		assert_equal loc1, s1.user_location
		# And a size check, just for fun
		loc1.reload
		assert_equal 2, loc1.sightings.size
	end
end
