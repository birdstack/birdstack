require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Just some basic sanity checks for the NOTIFICATION_TYPES constant
  def test_sanity
    # All notification types are valid methods
    u = users(:quentin)
    User::NOTIFICATION_TYPES.keys.each do |k|
      assert u.respond_to?(k), "#{k} is a valid user method"
    end

    short_codes = User::NOTIFICATION_TYPES.values.collect {|v| v[:short]}

    # no duplicate short codes
    assert short_codes.size == short_codes.uniq.size, "no duplicate short codes"

    # short codes 1 or 2 chars
    short_codes.each do |sc|
      assert sc =~ /^[a-z]{1,2}$/, "short #{sc} must be 1 or two chars"
    end

    descs = User::NOTIFICATION_TYPES.values.collect {|v| v[:desc]}

    # description exists and starts with lower case
    descs.each do |d|
      assert d =~ /^[a-z]/, "desc #{d} must start with lower case"
    end

    # sort code exists
    User::NOTIFICATION_TYPES.values.each do |v|
      assert !v[:sort].nil?
    end
  end
end
