require File.dirname(__FILE__) + '/../test_helper'

class AlternateNamesTest < ActiveSupport::TestCase
	def test_valid
		an = AlternateName.new(:name => 'monkey', :description => 'beans')
		an.user = users(:quentin)
		an.species = Species.find(:first, :conditions => ['change_id IS NULL'])
		assert an.save
	end

	def test_substring
		s = Species.find(:first, :conditions => ['change_id IS NULL'])
		an = AlternateName.new(:name => s.english_name.chop, :description => 'beans')
		an.user = users(:quentin)
		an.species = s
		assert !an.save
		assert an.errors.on(:name)
	end

	def test_substring_case
		s = Species.find(:first, :conditions => ['change_id IS NULL'])
		an = AlternateName.new(:name => s.english_name.chop.upcase, :description => 'beans')
		an.user = users(:quentin)
		an.species = s
		assert !an.save
		assert an.errors.on(:name)
	end
end
