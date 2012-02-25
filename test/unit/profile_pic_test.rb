require File.dirname(__FILE__) + '/../test_helper'

class ProfilePicTest < ActiveSupport::TestCase
	def test_accept_valid_pic
		valid_pic = File.new(File.dirname(__FILE__) + '/../../public/images/binoc_normal.png')
		u = users(:quentin)
                u.profile_pic = valid_pic
		assert u.save
	end

	def test_reject_invalid_pic
		invalid_pic = File.new(__FILE__)
		u = users(:quentin)
                u.profile_pic = invalid_pic
		assert !u.save
                assert u.errors.on(:profile_pic)
	end

	def test_reject_invalid_pic_with_valid_filename
		invalid_pic = File.new(File.dirname(__FILE__) + '/../data/bad_img.jpg')
		u = users(:quentin)
                u.profile_pic = invalid_pic
		assert !u.save
                assert u.errors.on(:profile_pic)
	end
end
