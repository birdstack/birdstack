require File.dirname(__FILE__) + '/../test_helper'

class ChangeTest < ActiveSupport::TestCase
	def test_change_detection
		# We start out with no pending changes
		assert_equal 0, User.find_by_login('quentin').pending_taxonomy_changes_count

		# We create one
		change = Change.new
		change.species = User.find_by_login('quentin').sightings.find(:first).species
		change.change_type = 'removal'
		change.description = 'cheese'
		change.date = Time::now()
		change.save!

		# And make sure we see it
		assert_equal 1, User.find_by_login('quentin').pending_taxonomy_changes_count
	end

	def test_change_change_type_enforcement
		change = Change.new
		change.species = User.find_by_login('quentin').sightings.find(:first).species
		change.change_type = 'lump'
		change.description = 'cheese'
		change.date = Time::now()
		assert !change.save

		# Should have an error because it needs 1 potential species
		assert change.errors.on(:potential_species)
	end
end
