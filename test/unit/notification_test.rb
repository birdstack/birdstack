require File.dirname(__FILE__) + '/../test_helper'

class NotificationTest < ActiveSupport::TestCase
	def test_self_link
		s = Species.find(:first)
		n = Notification.new(:description => 'test')
		n.user = users(:quentin)
		n.species = s
		n.potential_species << s
		
		assert !n.save
	end

	def test_valid
		s = Species.find(:all, :conditions => ['change_id IS NULL'], :limit => 2)
		n = Notification.new(:description => 'test')
		n.user = users(:quentin)
		n.species = s[0]
		n.potential_species << s[1]

		assert n.save
	end

	def test_link_to_old_species
		s = Species.find(:all, :conditions => ['change_id IS NULL'], :limit => 2)
		n = Notification.new(:description => 'test')
		n.user = users(:quentin)
		n.species = s[0]

		change = Change.new
		change.species = s[1]
		change.change_type = 'removal'
		change.description = 'cheese'
		change.date = Time::now()
		change.save!

		n.potential_species << s[1]

		assert !n.save
	end
end
