class GenSortAfter < ActiveRecord::Migration
  def self.assign_sort_after(list)
    while item = list.pop
      item.sort_after = list[-1]
      item.save!
    end
  end

  def self.up
    assign_sort_after(Order.all(:order => 'sort_order'))
    assign_sort_after(Family.all(:order => 'sort_order'))
    assign_sort_after(Genus.all(:order => 'sort_order'))
    assign_sort_after(Species.all(:order => 'sort_order'))
  end

  def self.down
  end
end
