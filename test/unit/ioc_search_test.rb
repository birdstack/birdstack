require File.dirname(__FILE__) + '/../test_helper'

class IocSearchTest < ActiveSupport::TestCase
	def test_search_length
		# We have a minimum search length of 3,
		# but some strings like "a1b2" get collapsed
		# to "ab" so what looks like a string that's long
		# enough actually isn't
		s = IocSearch.new
		s.term = "a12"
		assert !s.valid?
		assert s.errors.on(:term)
	end
end
