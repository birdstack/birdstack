class FixUserLocationCommentCollectionPrivacy < ActiveRecord::Migration
  def self.up
	  UserLocation.find(:all, :conditions => {:private => 1}).each do |location|
		  location.save
	  end
  end

  def self.down
  end
end
