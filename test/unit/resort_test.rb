require File.dirname(__FILE__) + '/../test_helper'

class ResortTest < ActiveSupport::TestCase
  include Birdstack::Resort

  def test_insert_first
    insert_first(Order.find_by_latin_name('blah3'))
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah3').sort_order
    assert_equal 2, Order.find_by_latin_name('blah').sort_order
    assert_equal 3, Order.find_by_latin_name('blah2').sort_order
  end

  # Verifies that the new family will be inserted very first
  # because this family belongs to the first order
  def test_insert_first_family_in_first_order
    f = Family.new
    f.latin_name = 'blah2'
    f.english_name = 'blah2'
    f.order = Order.find_by_latin_name('blah')
    insert_first(f)
    gen_sort_orders
    assert_equal 1, Family.find_by_latin_name('blah2').sort_order
    assert_equal 2, Family.find_by_latin_name('blah').sort_order
  end

  # This test verifies that the code will be able to correctly
  # identify that this new family should be sorted after the family
  # in the first order
  def test_insert_first_family_in_second_order
    f = Family.new
    f.latin_name = 'blah2'
    f.english_name = 'blah2'
    f.order = Order.find_by_latin_name('blah2')
    insert_first(f)
    gen_sort_orders
    assert_equal 1, Family.find_by_latin_name('blah').sort_order
    assert_equal 2, Family.find_by_latin_name('blah2').sort_order
  end

  # And this verifies that it can find that first family, even when
  # there's an empty family in between
  def test_insert_first_family_in_third_order
    f = Family.new
    f.latin_name = 'blah2'
    f.english_name = 'blah2'
    f.order = Order.find_by_latin_name('blah3')
    insert_first(f)
    gen_sort_orders
    assert_equal 1, Family.find_by_latin_name('blah').sort_order
    assert_equal 2, Family.find_by_latin_name('blah2').sort_order
  end

  def test_move_family_from_first_to_another_first
    # Insert family in 3rd order
    f = Family.new
    f.latin_name = 'blah2'
    f.english_name = 'blah2'
    f.order = Order.find_by_latin_name('blah3')
    insert_first(f)
    # Now move to first position in first order
    f.order = Order.find_by_latin_name('blah')
    insert_first(f)
    gen_sort_orders
    assert_equal 1, Family.find_by_latin_name('blah2').sort_order
    assert_equal 2, Family.find_by_latin_name('blah').sort_order
  end

  def test_move_family_from_middle_to_another_middle
    # Insert family in 1st order so there are now 2
    f = Family.new
    f.latin_name = 'blah2'
    f.english_name = 'blah2'
    f.order = Order.find_by_latin_name('blah')
    insert_after(Family.find_by_latin_name('blah'), f)
    
    # Insert families in 2nd order so there are now 3
    f = Family.new
    f.latin_name = 'blah3'
    f.english_name = 'blah3'
    f.order = Order.find_by_latin_name('blah2')
    insert_first(f)
    f = Family.new
    f.latin_name = 'blah5'
    f.english_name = 'blah5'
    f.order = Order.find_by_latin_name('blah2')
    insert_after(Family.find_by_latin_name('blah3'), f)
    f = Family.new
    f.latin_name = 'blah4'
    f.english_name = 'blah4'
    f.order = Order.find_by_latin_name('blah2')
    insert_after(Family.find_by_latin_name('blah3'), f)

    # Now move to middle position in first order
    f.order = Order.find_by_latin_name('blah')
    insert_after(Family.find_by_latin_name('blah'), f)
    gen_sort_orders
    assert_equal 1, Family.find_by_latin_name('blah').sort_order
    assert_equal 2, Family.find_by_latin_name('blah4').sort_order
    assert_equal 3, Family.find_by_latin_name('blah2').sort_order
    assert_equal 4, Family.find_by_latin_name('blah3').sort_order
    assert_equal 5, Family.find_by_latin_name('blah5').sort_order
  end

  def test_move_family_after_other_family_in_other_order
    f = Family.new
    f.latin_name = 'blah2'
    f.english_name = 'blah2'
    f.order = Order.find_by_latin_name('blah3')
    insert_first(f)
    # Can't have this one sorted after a family in another order
    assert_raise RuntimeError do
      insert_after(Family.find_by_latin_name('blah'), f)
    end
  end

  def test_move_bottom_up_one
    insert_after(Order.find_by_latin_name('blah'), Order.find_by_latin_name('blah3'))
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah').sort_order
    assert_equal 2, Order.find_by_latin_name('blah3').sort_order
    assert_equal 3, Order.find_by_latin_name('blah2').sort_order
  end

  def test_move_first_to_last
    insert_after(Order.find_by_latin_name('blah3'), Order.find_by_latin_name('blah'))
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah2').sort_order
    assert_equal 2, Order.find_by_latin_name('blah3').sort_order
    assert_equal 3, Order.find_by_latin_name('blah').sort_order
  end

  def test_move_first_to_last_last_to_first
    insert_first(Order.find_by_latin_name('blah3'))
    insert_after(Order.find_by_latin_name('blah2'), Order.find_by_latin_name('blah'))
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah3').sort_order
    assert_equal 2, Order.find_by_latin_name('blah2').sort_order
    assert_equal 3, Order.find_by_latin_name('blah').sort_order
  end

  def test_insert_same_position
    insert_after(Order.find_by_latin_name('blah2'), Order.find_by_latin_name('blah3'))
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah').sort_order
    assert_equal 2, Order.find_by_latin_name('blah2').sort_order
    assert_equal 3, Order.find_by_latin_name('blah3').sort_order
  end

  def test_insert_own_position
    insert_after(Order.find_by_latin_name('blah2'), Order.find_by_latin_name('blah2'))
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah').sort_order
    assert_equal 2, Order.find_by_latin_name('blah2').sort_order
    assert_equal 3, Order.find_by_latin_name('blah3').sort_order
  end

  def test_insert_same_position_middle
    insert_after(Order.find_by_latin_name('blah'), Order.find_by_latin_name('blah2'))
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah').sort_order
    assert_equal 2, Order.find_by_latin_name('blah2').sort_order
    assert_equal 3, Order.find_by_latin_name('blah3').sort_order
  end

  def test_insert_new_order_first
    o = Order.new
    o.latin_name = 'blah4'
    insert_first(o)
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah4').sort_order
    assert_equal 2, Order.find_by_latin_name('blah').sort_order
    assert_equal 3, Order.find_by_latin_name('blah2').sort_order
    assert_equal 4, Order.find_by_latin_name('blah3').sort_order
  end

  def test_insert_new_order_middle
    o = Order.new
    o.latin_name = 'blah4'
    insert_after(Order.find_by_latin_name('blah2'), o)
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah').sort_order
    assert_equal 2, Order.find_by_latin_name('blah2').sort_order
    assert_equal 3, Order.find_by_latin_name('blah4').sort_order
    assert_equal 4, Order.find_by_latin_name('blah3').sort_order
  end

  def test_insert_new_order_middle_then_move_first_after
    o = Order.new
    o.latin_name = 'blah4'
    insert_after(Order.find_by_latin_name('blah2'), o)
    insert_after(Order.find_by_latin_name('blah4'), Order.find_by_latin_name('blah'))
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah2').sort_order
    assert_equal 2, Order.find_by_latin_name('blah4').sort_order
    assert_equal 3, Order.find_by_latin_name('blah').sort_order
    assert_equal 4, Order.find_by_latin_name('blah3').sort_order
  end

  def test_insert_new_order_last
    o = Order.new
    o.latin_name = 'blah4'
    insert_after(Order.find_by_latin_name('blah3'), o)
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah').sort_order
    assert_equal 2, Order.find_by_latin_name('blah2').sort_order
    assert_equal 3, Order.find_by_latin_name('blah3').sort_order
    assert_equal 4, Order.find_by_latin_name('blah4').sort_order
  end

  def test_delete_first_order
    # Have to create a new first one because our real first one is used elsewhere
    # Stupid fixtures...
    o = Order.new
    o.latin_name = 'blah4'
    insert_first(o)
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah4').sort_order
    assert_equal 2, Order.find_by_latin_name('blah').sort_order
    assert_equal 3, Order.find_by_latin_name('blah2').sort_order
    assert_equal 4, Order.find_by_latin_name('blah3').sort_order

    Order.find_by_latin_name('blah4').destroy
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah').sort_order
    assert_equal 2, Order.find_by_latin_name('blah2').sort_order
    assert_equal 3, Order.find_by_latin_name('blah3').sort_order
  end

  def test_delete_middle_order
    Order.find_by_latin_name('blah2').destroy
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah').sort_order
    assert_equal 2, Order.find_by_latin_name('blah3').sort_order
  end

  def test_delete_last_order
    Order.find_by_latin_name('blah3').destroy
    gen_sort_orders
    assert_equal 1, Order.find_by_latin_name('blah').sort_order
    assert_equal 2, Order.find_by_latin_name('blah2').sort_order
  end
end
