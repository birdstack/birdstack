class FixRegionsMisspelling < ActiveRecord::Migration
  def self.up
	  execute("UPDATE regions SET description = 'Europe, Asia from the Middle East through central Asia north of the Himalayas, Siberia and northern China to Japan' WHERE code = 'EU'")
  end

  def self.down
  end
end
