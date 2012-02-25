module Birdstack
module Background
class ActivityGenerator
  MAX_TIME_SPAN = 1.hour

  # Remember that all activities are public!

  # A note on locking:
  # It's possible that a user could change the privacy level of a sighting, location, or trip while we're still in the process
  # of generating the description.  This will result in saving a description with private data.
  # So, to prevent that, we use pessimistic locks on all the sightings, locations, and trips we're looking at.  This prevents
  # any updates from executing on the records in question.  Then, we have optimistic locking turned on for those record types.
  # That means that if a user changes the privacy level while we're generating a description:
  # 1) We start generating the description, locking (SELECT FOR UPDATE) all the related records
  # 2) The user hits submit to change the privacy level of a record
  # 3) Rails loads the record for the user, changes the privacy level and goes to save it but is blocked because of Step #1
  # 4) We finish the description and save all the records, incrementing the lock version
  # 5) The save from #3 is no longer blocked but now fails because the lock version changed
  # 6) Logic in the Sighting/Location/Trip controller attempts to re-save the sighting, and all is well

  def self.generate_activities
    activities_generated = 0

    activities_generated += generate_activity_events_for_activity(Sighting)
    activities_generated += generate_activity_events_for_activity(SightingPhoto)
    activities_generated += generate_activity_events_for_activity(TripPhoto)
    activities_generated += generate_activity_events_for_activity(UserLocationPhoto)
  end

  def self.generate_activity_events_for_activity(activity_class)
    activities_generated = 0

    users = activity_class.public.all(:select => "DISTINCT #{activity_class.table_name}.user_id", :conditions => ["#{activity_class.table_name}.#{activity_class.name.underscore}_activity_id IS NULL"]).collect {|s| s.user}

    users.each do |u|
      # Find the most recent activity that does not have an activity event associated with it
      while(first_activity = u.send(activity_class.table_name).public.find(:first, :conditions => ["#{activity_class.table_name}.#{activity_class.name.underscore}_activity_id IS NULL"], :order => "#{activity_class.table_name}.created_at DESC")) do
        # Locking occurs within this transaction
        Activity.transaction do
          # Have to refind it so we can get that lock
          activities = [u.send(activity_class.table_name).public.find_by_id(first_activity.id, :lock => true)]
          next if activities.compact.empty? # It's possible (but unlikely) that it went away during this time

          # Loop, finding activities that occurred within an hour of the last activity
          while((other_activities = u.send(activity_class.table_name).public.find(:all, :conditions => ["#{activity_class.table_name}.#{activity_class.name.underscore}_activity_id IS NULL AND #{activity_class.table_name}.created_at <= ? AND #{activity_class.table_name}.created_at >= ? AND #{activity_class.table_name}.id NOT IN (?)", activities.last.created_at, activities.last.created_at - MAX_TIME_SPAN, activities.collect {|s| s.id}], :lock => true)).size > 0) do
            activities += other_activities
          end

          # Now, see if these activities should be tacked on to an existing activity event
          a = u.send(activity_class.name.underscore + "_activities").find(:first, :conditions => ['occurred_at >= ? and occurred_at <= ?', activities.last.created_at - MAX_TIME_SPAN, activities.first.created_at])
          if a then
            # If so, we need to bring in all the existing activities
            activities += a.send(activity_class.table_name).all(:lock => true)
          else
            # Nope, make a new one
            a = (activity_class.name+"Activity").constantize.new
            a.user = u
          end

          # At this point, we have enough to make an activity
          a.occurred_at = activities.first.created_at
          a.save!

          # Now that we have an ID, update all the related activities
          # Hard-coded to save time.  Takes care of updating the lock version
          u.send(activity_class.table_name).update_all("#{activity_class.table_name}.#{activity_class.name.underscore}_activity_id = #{a.id}, #{activity_class.table_name}.lock_version = #{activity_class.table_name}.lock_version + 1", ["#{activity_class.table_name}.id IN (?)", activities.collect{|s| s.id}] )

          # Now generate the description for the activity event, based on the activities
          # We don't have to do .publicize! on these because all we ever save is the ID
          activities_all = activities.collect {|s| s.id}

          a.description.merge!(self.send("generate_description_"+activity_class.name.underscore, activities_all, u))

          a.save!

          activities_generated += 1
        end
      end
    end

    activities_generated
  end

  private

  def self.generate_description_sighting_photo(sighting_photos_all, user)
    {
      :num_photos       => sighting_photos_all.size,
      :sighting_photos  => select_random!(sighting_photos_all, 3),
    }
  end

  def self.generate_description_trip_photo(trip_photos_all, user)
    {
      :num_photos   => trip_photos_all.size,
      :trip_photos  => select_random!(trip_photos_all, 3),
    }
  end

  def self.generate_description_user_location_photo(user_location_photos_all, user)
    {
      :num_photos   => user_location_photos_all.size,
      :user_location_photos  => select_random!(user_location_photos_all, 3),
    }
  end

  def self.generate_description_sighting(sightings_all, user)
    locations_all = user.user_locations.public.all(:conditions => ['user_locations.id IN (SELECT DISTINCT sightings.user_location_id FROM sightings WHERE sightings.id IN (?))', sightings_all], :lock => true).collect {|l| l.id }

    trips_all = user.trips.public.all(:conditions => ['trips.id IN (SELECT DISTINCT sightings.trip_id FROM sightings WHERE sightings.id IN (?))', sightings_all], :lock => true).collect {|t| t.id }

    description = {
      :num_locations  => locations_all.size,
      :locations      => select_random!(locations_all, 3),
      :num_sightings  => sightings_all.size,
      :sightings      => select_random!(sightings_all, 3),
      :num_trips      => trips_all.size,
      :trips          => select_random!(trips_all, 3)
    }

    # Now update the lock versions on the locations and trips we used for the description
    UserLocation.update_all("user_locations.lock_version = user_locations.lock_version + 1", ['user_locations.id IN (?)', description[:locations]])
    Trip.update_all("trips.lock_version = trips.lock_version + 1", ['trips.id IN (?)', description[:trips]])

    description
  end

  def self.select_random!(col, num)
    randoms = []
    1.upto(num) do
      break if col.empty?
      randoms << col.slice!(rand(col.length))
    end
    randoms
  end
end
end
end
