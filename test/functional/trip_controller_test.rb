require File.dirname(__FILE__) + '/../test_helper'
require 'trip_controller'

# Re-raise errors caught by the controller.
class TripController; def rescue_action(e) raise e end; end

class TripControllerTest < ActionController::TestCase
	fixtures :users

  def setup
    @controller = TripController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

	def test_create_casual_trip
		login_as :quentin
		post :add, :trip => {:name => 'test', :parent_id => ''}
		assert_redirected_to :controller => 'sighting', :action => 'select_species', :prefill => {:trip => users(:quentin).trips.find_by_name('test').id }
	end

	def test_load_page
		login_as :quentin
		get :add
		assert_response :success
	end

	def test_load_view
		login_as :quentin
		get :view, :user => users(:quentin).login, :id => 1
		assert_response :success
	end

	def test_delete_trip
		login_as :quentin
		post :delete, :id => trips(:sightinglesstrip).id
		assert_response :redirect
		assert !flash[:warning]
		assert !Trip.find_by_id(trips(:sightinglesstrip).id)
	end

        def test_rename_subtrip
          login_as :quentin

          trip = Trip.new(:name => 'subtrip')
          trip.user = users(:quentin)
          assert trip.save
          assert trip.move_to_child_of(users(:quentin).trips.find_by_name('awesome'))
          trip.reload
          post :edit, :id => trip.id, :trip => {:name => 'subtrip1', :parent_id => trip.parent_id.to_s}
          assert_response :redirect
          trip.reload
          assert_equal 'subtrip1', trip.name
        end

        def test_rename_subtrip_and_change_parent
          login_as :quentin

          trip = Trip.new(:name => 'subtrip')
          trip.user = users(:quentin)
          assert trip.save
          assert trip.move_to_child_of(users(:quentin).trips.find_by_name('awesome'))
          trip.reload
          post :edit, :id => trip.id, :trip => {:name => 'subtrip1', :parent_id => users(:quentin).trips.find_by_name('No sightings here!')}
          assert_response :redirect
          trip.reload
          assert_equal 'subtrip1', trip.name
        end

	def test_invalid_user
		get :view, :user => 'notauser'

		assert_redirected_to :controller => 'main', :action => 'index'
		assert flash[:warning]
	end

	def test_invalid_trip_logged_out
		get :view, :user => 'quentin', :id => 9999999

		assert_response :success
	end

	def test_invalid_trip_logged_in
		login_as :quentin
		get :view, :user => 'quentin', :id => 9999999

		assert_response :success
	end

        context "2 trips, one private, one not.  a subtrip on the public one" do
          setup do
            login_as :quentin

            @tripa = Trip.new(:name => 'privateparent')
            @tripa.private = 1
            @tripa.user = users(:quentin)
            assert @tripa.save

            @tripb = Trip.new(:name => 'publicparent')
            @tripb.user = users(:quentin)
            assert @tripb.save

            @tripc = Trip.new(:name => 'child')
            @tripc.user = users(:quentin)
            assert @tripc.save
            assert @tripc.move_to_child_of(@tripb)
            @tripc.reload
            assert @tripc.save
          end

          should "be able to be moved to be a child of the private on if it is simultaenously marked as private" do
            post :edit, :id => @tripc.id, :trip => {:private => 1, :parent_id => @tripa.id}
            assert_response :redirect
            @tripc.reload
            assert_equal true, @tripc.private
            assert_equal @tripa.id, @tripc.parent_id
          end
        end
end
