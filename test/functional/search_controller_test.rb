require File.dirname(__FILE__) + '/../test_helper'
require 'search_controller'

# Re-raise errors caught by the controller.
class SearchController; def rescue_action(e) raise e end; end

class SearchControllerTest < ActionController::TestCase
  def setup
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

	def test_temp_search
		login_as :quentin
		post :observation, :observation_tag => {:id => ["llama", "beans"]}
	end
end
