class SwitchToNulledSortAfter < ActiveRecord::Migration
  def self.up
    Order.all(:order => 'sort_order').each do |o|
      f = o.families.first(:order => 'sort_order')
      f.sort_after = nil
      f.save!
      o.families.all(:order => 'sort_order').each do |f|
        g = f.genera.first(:order => 'sort_order')
        g.sort_after = nil
        g.save!
        f.genera(:order => 'sort_order').each do |g|
          s = g.species.first(:order => 'sort_order')
          s.sort_after = nil
          s.save!
        end
      end
    end
  end

  def self.down
  end
end
