require File.dirname(__FILE__) + '/../test_helper'

class ListsControllerTest < ActionController::TestCase
	def test_invalid_user
		get :list, :user => 'notauser'

		assert_redirected_to :controller => 'main', :action => 'index'
		assert flash[:warning]
	end

	def test_empty_list
		ss = SavedSearch.new
		ss.user = users(:quentin)
		ss.search = Birdstack::Search.new(users(:quentin), {:observation_elevation => {:elevation_start => 9999999999, :elevation_units => 'm'}}, false, users(:quentin)).freeze
		ss.private = false
		ss.temp = false
		ss.name = 'no entries'
		ss.save!

		login_as :quentin
		get :list, :user => 'quentin', :id => ss.id, :format => 'atom'
		assert_response :success
	end

	def test_exports
		ss = SavedSearch.new
		ss.user = users(:quentin)
		ss.search = Birdstack::Search.new(users(:quentin), {
			:observation_search_display => {:type => "table", :sort => "date_desc"},
			:observation_search_type => {:type => "earliest"}
                }, false, users(:quentin)).freeze
		ss.private = false
		ss.temp = false
		ss.name = 'life list'
		ss.save!

		login_as :quentin

		get :list, :user => 'quentin', :id => ss.id, :format => 'html'
		assert_response :success
                assert @response.body =~ /<html/

		get :list, :user => 'quentin', :id => ss.id, :format => 'atom'
		assert_response :success
                assert !(@response.body =~ /<html/)

		get :export, :user => 'quentin', :id => ss.id, :format => 'csv'
		assert_response :success
                assert !(@response.body =~ /<html/)

		get :export, :user => 'quentin', :id => ss.id, :format => 'xml'
		assert_response :success
                assert !(@response.body =~ /<html/)
	end
end
