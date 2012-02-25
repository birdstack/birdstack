require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper

  def test_should_create_user
    assert_difference User, :count do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_comment_collection
    assert_difference User, :count do
      user = create_user
      assert user.comment_collection
    end
  end

  def test_delete_with_comment_collection
    assert_no_difference User, :count do
      user = create_user
      user.destroy
      assert user.frozen?
      assert user.comment_collection.frozen?
      assert_equal nil, user.comment_collection.user
      assert !CommentCollection.find_by_id(user.comment_collection.id)
    end
  end

  def test_should_require_login
    assert_no_difference User, :count do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_user_agreement
    assert_no_difference User, :count do
      u = create_user(:user_agreement => '')
      assert u.errors.on(:user_agreement)
    end
  end

  def test_should_require_age_verification
    assert_no_difference User, :count do
      u = create_user(:age_verification => '')
      assert u.errors.on(:age_verification)
    end
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_not_accept_blank_password_on_update
    assert_no_difference User, :count do
      u = users(:quentin)
      u.update_attributes(:password => '', :password_confirmation => '')
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    # On new user
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => '')
      assert u.errors.on(:password)
    end

    # On update
    assert_no_difference User, :count do
      u = users(:quentin)
      u.update_attributes(:password => 'new password', :password_confirmation => '')
      assert u.errors.on(:password)
    end
    
    # On update, even if they're stupid and type in the wrong box
    assert_no_difference User, :count do
      u = users(:quentin)
      u.update_attributes(:password => '', :password_confirmation => 'adsfasljklkjlkjdf')
      assert u.errors.on(:password)
    end
  end

  def test_should_require_email_verification
    # On new user
    assert_no_difference User, :count do
      u = create_user(:email_confirmation => '')
      assert u.errors.on(:email)
    end

    # On update
    assert_no_difference User, :count do
      u = users(:quentin)
      u.update_attributes(:email => 'cheese@beans.com', :email_confirmation => '')
      assert u.errors.on(:email)
    end
    
    # On update, even if they're stupid and type in the wrong box
    assert_no_difference User, :count do
      u = users(:quentin)
      u.update_attributes(:email => '', :email_confirmation => 'adsfasljklkjlkjdf')
      assert u.errors.on(:email)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  def test_should_reject_invalid_gender
    u = users(:quentin)
    u.gender = 'weird'
    u.save
    assert u.errors.on(:gender)
  end

  def test_should_accept_valid_gender
    u = users(:quentin)
    u.gender = 'm'
    u.save
    assert !u.errors.on(:gender)
  end

  def test_should_reject_invalid_url
	  u = users(:quentin)
	  u.website = 'http://@#$.com/wrong'
	  u.save
	  assert u.errors.on(:website)
  end

  def test_should_reject_invalid_url_protocol
	  u = users(:quentin)
	  u.website = 'ftp://ftp.example.com/'
	  u.save
	  assert u.errors.on(:website)
  end

  def test_should_accept_valid_url
	  u = users(:quentin)
	  u.website = 'http://google.com/'
	  u.save
	  assert !u.errors.on(:website)
  end

  def test_should_accept_valid_signature
	  u = users(:quentin)
	  u.signature = 'i rock'
	  u.save
	  assert !u.errors.on(:signature)
  end

  def test_should_reject_valid_signature
	  u = users(:quentin)
	  too_long = '1'
	  (1..1000).each { too_long += '1' }
          u.signature = too_long
	  u.save
	  assert u.errors.on(:signature)
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes!(:login => 'quentin2')
    assert_equal users(:quentin), User.authenticate('quentin2', 'testing123456')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin', 'testing123456')
  end

  def test_should_authenticate_user_regardless_of_username_case
    assert_equal users(:quentin), User.authenticate('QuEnTiN', 'testing123456')
  end

  def test_should_not_authenticate_user_with_different_password_case
    assert_equal nil, User.authenticate('quentin', 'TeStInG123456')
  end

  def test_should_create_and_own_comment_collection
	  u = nil

	  assert_difference CommentCollection, :count do
		  u = create_user
	  end

	  assert u.comment_collection
	  assert_equal u, u.comment_collection.user
  end

  private
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :email_confirmation => 'quire@example.com', :password => 'quire123456', :password_confirmation => 'quire123456', :user_agreement => '1', :age_verification => '1' }.merge(options))
    end
end
