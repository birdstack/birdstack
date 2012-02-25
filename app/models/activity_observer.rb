class ActivityObserver < ActiveRecord::Observer
  # This observer takes care of updating activities if a user changes something related to an activity
  # after the activity description has been generated.  For example, if a user marks a sightings as private,
  # it needs to be immediately removed from the activity and from the activity description.  Similarly, if
  # a user renames a location, the activity description may have included it, and needs to be regenerated.
  # Or, if an item is deleted, it also needs to be removed.
  #
  # This could potentially be a very expensive operation.  For example, a user could have thousands of sightings
  # spanning months of data that belong to a single location.  If they change that location, then all of those
  # activities need to be regenerated.  So, rather than do it now, we'll just delete everything and let the
  # background process regenerate it.
  
  observe :sighting, :user_location, :trip, :sighting_photo

  def after_save(item)
    destroy_activities(item)
  end

  def after_destroy(item)
    destroy_activities(item)
  end

  private

  def destroy_activities(item)
    activities = Set.new

    if(item.is_a?(UserLocation) || item.is_a?(Trip)) then
      item.sightings.each do |s|
        activities << s.sighting_activity
      end
    elsif(item.is_a?(Sighting))
      activities << item.sighting_activity
    elsif(item.is_a?(SightingPhoto))
      activities << item.sighting_photo_activity
    end

    activities.each do |a|
      next if a.nil?

      if(a.is_a?(SightingActivity)) then
        a.sightings.update_all("sighting_activity_id = NULL")
        a.destroy
      elsif(a.is_a?(SightingPhotoActivity)) then
        a.sighting_photos.update_all("sighting_photo_activity_id = NULL")
        a.destroy
      end
    end
  end
end
