require File.dirname(__FILE__) + '/../test_helper'

class ContactTest < ActiveSupport::TestCase
  def test_should_require_name
      contact = Contact.new(:name => '')
      contact.valid?
      assert contact.errors.on(:name)
      assert !contact.save
  end
end
