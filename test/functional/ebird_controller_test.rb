require File.dirname(__FILE__) + '/../test_helper'

class EbirdControllerTest < ActionController::TestCase
  def test_generate_and_download
    login_as :quentin

    # Generate an all observations search
    search = Birdstack::Search.new(users(:quentin), {
          :observation_search_display => {:type => "table", :sort => "date_desc"},
          :observation_search_type => {:type => "all"}
    }, false, users(:quentin))
    ss = SavedSearch.new()
    ss.user = users(:quentin)
    ss.private = false
    ss.temp = false
    ss.name = 'All observations'
    ss.search = search.freeze
    ss.save!

    get :generate, :id => ss.id
    assert_response :success

    get :download, :id => users(:quentin).ebird_exports[0].id
    assert_response :success
    assert @response.body =~ /monkey/
  end
end
