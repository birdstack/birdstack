class CountryCode < ActiveRecord::Base
  class << self
    extend ActiveSupport::Memoizable

    def country_name(cc)
      country_code = CountryCode.find_by_cc(cc)
      if country_code.nil? then
        return cc
      else
        return country_code.name
      end
    end
    memoize :country_name
  end
end
