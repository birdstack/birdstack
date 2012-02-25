require "#{File.dirname(__FILE__)}/../test_helper"

class TagsTest < ActionController::IntegrationTest
	# Make sure that tags containing periods get routed correctly
	def test_tags_with_periods
		get '/people/quentin/observations/tags/blah.blah'
		assert_response :success

		get '/people/quentin/observations/tags/blah.blah.blah'
		assert_response :success
	end
end
