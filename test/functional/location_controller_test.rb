require File.dirname(__FILE__) + '/../test_helper'
require 'location_controller'

# Re-raise errors caught by the controller.
class LocationController; def rescue_action(e) raise e end; end

class LocationControllerTest < ActionController::TestCase
	fixtures :sightings, :users, :trips

	def setup
		@controller = LocationController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_associate_with_sighting
		login_as :quentin
		post :add, :user_location => {:name => 'test'}, :prefill => {:sighting => sightings(:genericbird).id}
		assert_response :redirect
		assert_equal Sighting.find_by_id(sightings(:genericbird).id).user_location_id, users(:quentin).user_locations.find_by_name('test').id
	end

	def test_associate_with_sighting_with_trip
		login_as :quentin
		post :add, :user_location => {:name => 'test'}, :prefill => {:sighting => sightings(:birdonatrip).id}
		assert_response :redirect
		assert_redirected_to :controller => 'sighting', :action => 'select_species', :prefill => {:location => users(:quentin).user_locations.find_by_name('test').id, :sighting => sightings(:birdonatrip).id }
		assert_equal Sighting.find_by_id(sightings(:birdonatrip).id).user_location_id, users(:quentin).user_locations.find_by_name('test').id
	end

	def test_add_new_location
		login_as :quentin
		post :add, :user_location => {:name => 'testawesome'}
		assert_response :redirect
		assert_equal 'testawesome', UserLocation.find_by_name('testawesome').name
	end

	def test_invalid_user
		get :view, :user => 'notauser'

		assert_redirected_to :controller => 'main', :action => 'index'
		assert flash[:warning]
	end

	def test_null_autocomplete_adm1
		login_as :quentin
		get :auto_complete_for_adm1

		assert_response :success
	end

	def test_null_autocomplete_adm2
		login_as :quentin
		get :auto_complete_for_adm2

		assert_response :success
	end

	def test_null_autocomplete_location
		login_as :quentin
		get :auto_complete_for_location

		assert_response :success
	end
end
