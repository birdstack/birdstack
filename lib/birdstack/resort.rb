module Birdstack::Resort
  def gen_sort_orders
    gen_sort_orders_container(Order)
  end

  def gen_sort_orders_container(container, sort_orders = {})
    return if container.nil?

    container.update_all('sort_order = NULL')
    i = nil
    while(i = container.find_by_sort_after_id(i.andand.id)) do
      sort_orders[i.class] ||= 0
      i.sort_order = (sort_orders[i.class] += 1)
      i.save!
      gen_sort_orders_container(i.send(i.children), sort_orders) if i.children
    end
  end

  # TODO this needs to correctly handle the case of inserting something first in the list (sort_after=nil)
  # when there is already something first in the list.  There might even be a special case for inserting
  # something into the list as first if there is currently only 1 item in the list.
  def insert_first(new)
    insert_after(nil, new)
  end

  def insert_after(sort_after, new)
    if(sort_after.andand.parent and sort_after.send(sort_after.parent) != new.send(new.parent)) then
      new_parent = new.send(new.parent)
      sort_after_parent = sort_after.send(sort_after.parent)
      raise "Cannot sort #{new.class}:#{new.id}:#{new.latin_name}, parent #{new_parent.class}:#{new_parent.id}:#{new_parent.latin_name} after a taxon (#{sort_after.class}:#{sort_after.id}:#{sort_after.latin_name}, parent #{sort_after_parent.class}:#{sort_after_parent.id}:#{sort_after_parent.latin_name}) that belongs to a different parent!"
    end
    if !new.new_record? then
      if(new == sort_after) then
        # Can't move after myself
        return
      end
      if(
        ((new.parent and !new.send((new.parent.to_s + "_id_changed?").to_sym)) or !new.parent) and
        (new.sort_after == sort_after)
      ) then
          # Already there
          return
      end


      # Prepare the next record for our move
      if(old_below = new.class.find_by_sort_after_id(new.id)) then
        old_below.sort_after = new.sort_after
        if(old_below.sort_after_id == old_below.id) then
          raise "tried to create loop!"
        end
        old_below.save!
      end
    end

    # Need to find this before we save 'new'
    new_below = new.sibling_by_sort_after(sort_after)

    new.sort_after = sort_after
    if(!new.new_record? and (new.sort_after_id == new.id)) then
      raise "tried to create loop!"
    end
    new.save!

    # Now that 'new' has been saved, we can resave new_below
    if(new_below) then
      new_below.sort_after = new
      if(new_below.sort_after_id == new_below.id) then
        raise "tried to create loop!"
      end
      new_below.save!
    end
  end
end
