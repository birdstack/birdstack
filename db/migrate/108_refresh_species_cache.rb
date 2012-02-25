class RefreshSpeciesCache < ActiveRecord::Migration
  def self.up
	Species.find(:all).each {|s| s.skip_parent_update = true; s.save! }
	Genus.find(:all).each {|g| g.skip_parent_update = true; g.save! }
	Family.find(:all).each {|f| f.skip_parent_update = true; f.save! }
	Order.find(:all).each {|o| o.save! }
  end

  def self.down
  end
end
