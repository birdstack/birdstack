require File.dirname(__FILE__) + '/../test_helper'

class PendingImportItemTest < ActiveSupport::TestCase
	def test_pre_realization
		import = PendingImport.new
		import.user = users(:joe)
		import.filename = 'test.csv'
		import.save
		item = PendingImportItem.new(:line => 1, :english_name => 'American Robin')
		import.pending_import_items << item
		item.save
		assert item.pre_realization
	end

	def test_realization_success
		import = PendingImport.new
		import.user = users(:joe)
		import.filename = 'test.csv'
		import.save
		item = PendingImportItem.new(:line => 1, :english_name => 'American Robin')
		import.pending_import_items << item
		item.save
		assert_difference users(:joe).sightings, :count do
			assert item.realize
		end
	end

	def test_realization_failure
		import = PendingImport.new
		import.user = users(:joe)
		import.filename = 'test.csv'
		import.save
		item = PendingImportItem.new(:line => 1, :english_name => 'American Robin')
		item.date_year = -1 # This should cause it to fail
		import.pending_import_items << item
		item.save
		assert_no_difference users(:joe).sightings, :count do
			assert !item.realize
		end
	end

	def test_realization_failure_on_bad_url
		import = PendingImport.new
		import.user = users(:joe)
		import.filename = 'test.csv'
		import.save
		item = PendingImportItem.new(:line => 1, :english_name => 'American Robin')
		item.link = 'http://!@#$%^&*(' # This should cause it to fail
		import.pending_import_items << item
		item.save
		assert_no_difference users(:joe).sightings, :count do
			assert !item.realize
		end

		item.link = 'http://google.com' # This should cause it to succeed
		item.save
		assert_difference users(:joe).sightings, :count do
			assert item.realize
		end
	end
	
	def test_realization_of_tags
		import = PendingImport.new
		import.user = users(:joe)
		import.filename = 'test.csv'
		import.save
		item = PendingImportItem.new(:line => 1, :english_name => 'American Robin')
		item.tag_list = 'cheese,beans'
		import.pending_import_items << item
		item.save
		assert_difference users(:joe).sightings, :count do
			assert item.realize
			assert item.sighting.tag_list.include?('cheese')
			assert item.sighting.tag_list.include?('beans')
		end
	end
end
