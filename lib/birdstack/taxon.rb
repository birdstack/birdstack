module Birdstack::Taxon
  def before_destroy_sort_after
    after = self.class.find_by_sort_after_id(self.id)
    if(after)
      after.sort_after = self.sort_after
      after.save!
    end
    true
  end

  def sibling_by_sort_after(sort_after)
    if self.parent then
      self.send(self.parent).send(self.class.to_s.pluralize.underscore.to_sym).find_by_sort_after_id(sort_after.andand.id)
    else
      self.class.find_by_sort_after_id(sort_after.andand.id)
    end
  end

  def self.included(base)
    base.send(:before_destroy, :before_destroy_sort_after)
  end
end
