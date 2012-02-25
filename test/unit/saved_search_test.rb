require File.dirname(__FILE__) + '/../test_helper'

class SavedSearchTest < ActiveSupport::TestCase
	def test_publicize
		saved_search = SavedSearch.new(:name => 'test', :search => '', :private => 1)
		saved_search.user = users(:quentin)
		assert_raise RuntimeError do
			saved_search.publicize!
		end

		# And make sure we allow ourselves to view it
		saved_search = SavedSearch.new(:private => 1)
		saved_search.user = users(:quentin)
		assert_nothing_raised do
			saved_search.publicize!(users(:quentin))
		end

		assert saved_search.frozen?
		assert saved_search.readonly?

		# We can publicize it twice
		assert_nothing_raised do
		      saved_search.publicize!(users(:quentin))
		end

		# But not for a different user
		assert_raise RuntimeError do
		      saved_search.publicize!
		end
	end

end
