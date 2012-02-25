class AddInitialForums < ActiveRecord::Migration
  def self.up
	  Forum.create(:name => 'Bird Identification', :description => "Got a bird you can't ID?  This is the place to ask for help.", :url => 'bird-identification', :sort_order => 0)
	  Forum.create(:name => 'Bird Name Help', :description => 'If you cannot find the name of your bird in our database, someone may be able to help you here.', :url => 'bird-name-help', :sort_order => 1)
  end

  def self.down
	  Forum.find(:all).each do |f|
		  f.destroy
	  end
  end
end
