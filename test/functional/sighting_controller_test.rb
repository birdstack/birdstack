require File.dirname(__FILE__) + '/../test_helper'
require 'sighting_controller'

# Re-raise errors caught by the controller.
class SightingController; def rescue_action(e) raise e end; end

class SightingControllerTest < ActionController::TestCase
	def setup
		@controller = SightingController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_one_search_english_species_result
		login_as :quentin
		get :species_english_search, :species_english_name => 'American Robin'
                robin_id = Species.find_by_english_name('American Robin').id
		assert_redirected_to :controller => :sighting, :action => :add, :id => robin_id, :prefill => {:species => robin_id}
	end

	def test_multiple_search_english_species_result
		login_as :quentin
		get :species_english_search, :species_english_name => 'American'
		assert_response :success
	end

	def test_less_than_3_char_search
		login_as :quentin
		get :species_english_search, :species_english_name => 'c'
		assert_response :success
	end

	def test_retain_new_location_setting_on_error
		login_as :quentin
		post :add, :id => 1, :sighting => { :user_location_id => 0, :date_year => 'monkeys!' }
		assert_response :success
		assert @response.body =~ /<option value="0" selected="selected">Add a new location<\/option>/
	end

	def test_add_new_location
		login_as :quentin
		post :add, :id => 1, :sighting => { :user_location_id => 0 }
                assert_response :redirect
		assert_equal :location, @response.redirected_to[:controller]
		assert_equal :add, @response.redirected_to[:action]
	end

	def test_choose_no_location_even_with_prefill
		login_as :joe
		# Make sure that even though we prefilled for joehome, the sighting is not added there
		assert_no_difference user_locations(:joehome).sightings, :count do
			post :add, :id => 1, :sighting => {:user_location_id => ''}, :prefill => {:location => user_locations(:joehome).id}
			assert @response.redirected_to.include?("/people/joe/observations/")
		end
	end

	def test_import_prefill
		login_as :joe
		# The point here is that the presence of import information doesn't delete things like the species
		# info.  That can happen if @sighting is replaced by a 'realized' pending
		# import item and then not filled in with the selected species id
		# Failure here will probably generate an exception

		# Make sure we got an object to work with
		item = pending_import_items(:badentry)
		item.realize_without_save
		assert item.sighting

		get :add, :id => 1, :prefill => {:pending_import => pending_imports(:joesimport).id, :pending_import_item => item.id}
		assert_response :success
		assert @response.body =~ /American Robin/
	end

        context "Joe's pending import item" do
          setup do
            login_as :joe

            @pending_import = PendingImport.new
            @pending_import.user = users(:joe)
            @pending_import.filename = 'test.csv'
            @pending_import.description = 'test'
            assert @pending_import.save

            @pending_import_item = PendingImportItem.new
            @pending_import_item.pending_import = @pending_import
            @pending_import_item.english_name = 'blah'
            assert @pending_import_item.save
          end

          context "without ebird_exclude" do
            setup do
              @pending_import.ebird_exclude = false
              assert @pending_import.save
            end

            should "save without ebird_exclue" do
              assert_difference users(:joe).sightings, :count do
                post :add, :id => 1, :sighting => {:user_location_id => '', :trip_id => ''}, :prefill => {:pending_import => @pending_import.id, :pending_import_item => @pending_import_item.id}
              end
              assert_equal ({:controller => 'import', :action => 'pending', :id => @pending_import.id}), @response.redirected_to
              assert_response :redirect
              assert_equal false, users(:joe).sightings.first(:order => 'id DESC').ebird_exclude
                
              # And make sure the pending item was deleted
              assert_nil PendingImportItem.find_by_id(@pending_import_item.id)
            end
          end

          context "with ebird_exclude" do
            setup do
              @pending_import.ebird_exclude = true
              assert @pending_import.save
            end

            should "save with ebird_exclue" do
              assert_difference users(:joe).sightings, :count do
                post :add, :id => 1, :sighting => {:user_location_id => '', :trip_id => ''}, :prefill => {:pending_import => @pending_import.id, :pending_import_item => @pending_import_item.id}
              end
              assert_equal ({:controller => 'import', :action => 'pending', :id => @pending_import.id}), @response.redirected_to
              assert_response :redirect
              assert_equal true, users(:joe).sightings.first(:order => 'id DESC').ebird_exclude
                
              # And make sure the pending item was deleted
              assert_nil PendingImportItem.find_by_id(@pending_import_item.id)
            end
          end
	end

	def test_simple_add
		login_as :quentin
		# Make sure we don't misinterpret '' as 0, which would mean add a new location or trip
		post :add, :id => 1, :sighting => {:user_location_id => '', :trip_id => ''}
		assert @response.redirected_to.include?("/people/quentin/observations/")
	end

	def test_invalid_user
		get :view, :user => 'notauser'

		assert_redirected_to :controller => :main, :action => :index
		assert flash[:warning]
	end
end
