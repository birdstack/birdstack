require 'csv'

class ExportJob < Struct.new(:user_id)
  def self.format_comment_collection(comment_collection)
    return "" unless comment_collection.comments

    ret = ""
    
    comment_collection.comments.each do |comment|
      ret += comment.user.login + " (#{comment.created_at})\n"
      ret += comment.comment + "\n"
      ret += "======\n"
    end

    return ret
  end

  def perform
    user = User.find(self.user_id)

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        zipname = "birdstack-export-#{user.login}-" +
                  "#{Time.now.getutc.strftime('%FT%H%M%SZ')}.zip"

        # messages
        # profile
        # saved searches
        open("friends.csv", 'w') {|f| self.friends(user, f) }
        open("photos-sightings.csv", 'w') {|f| self.photos_sightings(user, f) }
        open("photos-locations.csv", 'w') {|f| self.photos_locations(user, f) }
        open("photos-trips.csv", 'w') {|f| self.photos_trips(user, f) }
        open("sightings.csv", 'w') {|f| self.sightings(user, f) }
        open("trips.csv", 'w') {|f| self.trips(user, f) }
        open("locations.csv", 'w') {|f| self.locations(user, f) }
        open("taxo-species.csv", 'w') {|f| self.species(f) }
        open("taxo-families.csv", 'w') {|f| self.families(f) }
        open("taxo-genera.csv", 'w') {|f| self.genera(f) }
        open("taxo-orders.csv", 'w') {|f| self.orders(f) }
        open("taxo-changes.csv", 'w') {|f| self.changes(f) }

        user.ebird_exports.each do |e|
          system("ln", e.full_filename, ".")
        end

        system("zip #{zipname} *")
        user.export = File.open(zipname)
      end
    end
    user.export_started = nil
    user.save
  end

  SIGHTINGS_EXPORTS = [
    ['id'],
    ['species_id'],
    ['species_english_name', lambda {|s| s.species.english_name }],
    ['species_scientific_name', lambda do |s|
      "#{s.species.genus.latin_name} #{s.species.latin_name}"
    end],
    ['created_at'],
    ['updated_at'],
    ['location_name', lambda {|s| s.user_location.andand.name }],
    ['user_location_id'],
    ['date_day'],
    ['date_month'],
    ['date_year'],
    ['trip_id'],
    ['species_count'],
    ['juvenile_male'],
    ['juvenile_female'],
    ['juvenile_unknown'],
    ['immature_male'],
    ['immature_female'],
    ['immature_unknown'],
    ['adult_male'],
    ['adult_female'],
    ['adult_unknown'],
    ['unknown_male'],
    ['unknown_female'],
    ['unknown_unknown'],
    ['notes'],
    ['time_hour'],
    ['time_minute'],
    ['comment_collection', lambda {|s| format_comment_collection(s.comment_collection) }],
    ['private'],
    ['exported_to_ebird', lambda {|s| s.ebird ? 'true' : 'false' }],
    ['ebird_exclude'],
    ['tags', lambda {|s| CSV.generate_line(s.tags.collect {|t| t.name})}],
    ['link'],
  ]

  def sightings(user, f)
    f.write(CSV.generate_line(SIGHTINGS_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    user.sightings.find_each do |sighting|
      f.write(CSV.generate_line(
        SIGHTINGS_EXPORTS.collect do |e|
          if e.length == 1 then
            sighting.send(e[0])
          else
            e[1].call(sighting)
          end
        end
      ))
      f.write("\r\n")
    end
  end

  def friends(user, f)
    f.write(user.friends.collect {|f| f.login}.join("\n"))
  end

  TRIP_EXPORTS = [
    ['id'],
    ['name'],
    ['description'],
    ['parent_id'],
    ['created_at'],
    ['updated_at'],
    ['time_hour_start'],
    ['time_minute_start'],
    ['protocol'],
    ['number_observers'],
    ['duration_hours'],
    ['duration_minutes'],
    ['distance_traveled_mi'],
    ['distance_traveled_km'],
    ['area_covered_acres'],
    ['area_covered_sqmi'],
    ['area_covered_sqkm'],
    ['date_day_start'],
    ['date_month_start'],
    ['date_year_start'],
    ['all_observations_reported'],
    ['date_day_end'],
    ['date_month_end'],
    ['date_year_end'],
    ['comment_collection', lambda {|s| format_comment_collection(s.comment_collection) }],
    ['private'],
    ['tags', lambda {|s| CSV.generate_line(s.tags.collect {|t| t.name})}],
    ['link'],
  ]

  def trips(user, f)
    f.write(CSV.generate_line(TRIP_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    user.trips.find_each do |trip|
      f.write(CSV.generate_line(
        TRIP_EXPORTS.collect do |e|
          if e.length == 1 then
            trip.send(e[0])
          else
            e[1].call(trip)
          end
        end
      ))
      f.write("\r\n")
    end
  end

  LOCATION_EXPORTS = [
    ['id'],
    ['cc'],
    ['adm1'],
    ['adm2'],
    ['location'],
    ['name'],
    ['notes'],
    ['latitude'],
    ['longitude'],
    ['zoom'],
    ['source'],
    ['created_at'],
    ['updated_at'],
    ['ecoregion'],
    ['elevation_ft'],
    ['elevation_m'],
    ['comment_collection', lambda {|s| format_comment_collection(s.comment_collection) }],
    ['private'],
    ['tags', lambda {|s| CSV.generate_line(s.tags.collect {|t| t.name})}],
    ['link'],
  ]

  def locations(user, f)
    f.write(CSV.generate_line(LOCATION_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    user.user_locations.find_each do |location|
      f.write(CSV.generate_line(
        LOCATION_EXPORTS.collect do |e|
          if e.length == 1 then
            location.send(e[0])
          else
            e[1].call(location)
          end
        end
      ))
      f.write("\r\n")
    end
  end

  SPECIES_EXPORTS = [
    ['id'],
    ['sort_order'],
    ['genus_id'],
    ['english_name'],
    ['latin_name'],
    ['breeding_subregions'],
    ['nonbreeding_regions'],
    ['change_id'],
    ['note'],
    ['code'],
  ]

  def species(f)
    f.write(CSV.generate_line(SPECIES_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    Species.find_each do |species|
      f.write(CSV.generate_line(
        SPECIES_EXPORTS.collect do |e|
          if e.length == 1 then
            species.send(e[0])
          else
            e[1].call(species)
          end
        end
      ))
      f.write("\r\n")
    end
  end

  GENUS_EXPORTS = [
    ['id'],
    ['sort_order'],
    ['family_id'],
    ['latin_name'],
    ['species_count'],
    ['note'],
    ['code'],
  ]

  def genera(f)
    f.write(CSV.generate_line(GENUS_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    Genus.find_each do |genus|
      f.write(CSV.generate_line(
        GENUS_EXPORTS.collect do |e|
          if e.length == 1 then
            genus.send(e[0])
          else
            e[1].call(genus)
          end
        end
      ))
      f.write("\r\n")
    end
  end

  FAMILY_EXPORTS = [
    ['id'],
    ['sort_order'],
    ['order_id'],
    ['latin_name'],
    ['english_name'],
    ['genus_count'],
    ['note'],
    ['code'],
  ]

  def families(f)
    f.write(CSV.generate_line(FAMILY_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    Family.find_each do |family|
      f.write(CSV.generate_line(
        FAMILY_EXPORTS.collect do |e|
          if e.length == 1 then
            family.send(e[0])
          else
            e[1].call(family)
          end
        end
      ))
      f.write("\r\n")
    end
  end

  ORDER_EXPORTS = [
    ['id'],
    ['sort_order'],
    ['latin_name'],
    ['family_count'],
    ['note'],
    ['code'],
  ]

  def orders(f)
    f.write(CSV.generate_line(ORDER_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    Order.find_each do |order|
      f.write(CSV.generate_line(
        ORDER_EXPORTS.collect do |e|
          if e.length == 1 then
            order.send(e[0])
          else
            e[1].call(order)
          end
        end
      ))
      f.write("\r\n")
    end
  end

  CHANGE_EXPORTS = [
    ['id'],
    ['date'],
    ['description'],
    ['change_type'],
    ['species', lambda {|c| CSV.generate_line(c.potential_species.collect {|s| s.id})}],
  ]

  def changes(f)
    f.write(CSV.generate_line(CHANGE_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    Change.find_each do |change|
      f.write(CSV.generate_line(
        CHANGE_EXPORTS.collect do |e|
          if e.length == 1 then
            change.send(e[0])
          else
            e[1].call(change)
          end
        end
      ))
      f.write("\r\n")
    end
  end

  PHOTOS_SIGHTINGS_EXPORTS = [
    ['id'],
    ['photo_file_name'],
    ['title'],
    ['description'],
    ['sighting_id'],
    ['created_at'],
    ['updated_at'],
    ['private'],
    ['comment_collection', lambda {|s| format_comment_collection(s.comment_collection) }],
    ['license'],
  ]

  def photos_sightings(user, f)
    f.write(CSV.generate_line(PHOTOS_SIGHTINGS_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    user.sighting_photos.find_each do |photo|
      f.write(CSV.generate_line(
        PHOTOS_SIGHTINGS_EXPORTS.collect do |e|
          if e.length == 1 then
            photo.send(e[0])
          else
            e[1].call(photo)
          end
        end
      ))
      f.write("\r\n")

      # and copy the photo
      system("ln", photo.photo.path, "sighting-#{photo.id}-#{photo.photo_file_name}")
    end
  end

  PHOTOS_LOCATIONS_EXPORTS = [
    ['id'],
    ['photo_file_name'],
    ['title'],
    ['description'],
    ['user_location_id'],
    ['created_at'],
    ['updated_at'],
    ['private'],
    ['comment_collection', lambda {|s| format_comment_collection(s.comment_collection) }],
    ['license'],
  ]

  def photos_locations(user, f)
    f.write(CSV.generate_line(PHOTOS_LOCATIONS_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    user.user_location_photos.find_each do |photo|
      f.write(CSV.generate_line(
        PHOTOS_LOCATIONS_EXPORTS.collect do |e|
          if e.length == 1 then
            photo.send(e[0])
          else
            e[1].call(photo)
          end
        end
      ))
      f.write("\r\n")

      # and copy the photo
      system("ln", photo.photo.path, "location-#{photo.id}-#{photo.photo_file_name}")
    end
  end

  PHOTOS_TRIPS_EXPORTS = [
    ['id'],
    ['photo_file_name'],
    ['title'],
    ['description'],
    ['trip_id'],
    ['created_at'],
    ['updated_at'],
    ['private'],
    ['comment_collection', lambda {|s| format_comment_collection(s.comment_collection) }],
    ['license'],
  ]

  def photos_trips(user, f)
    f.write(CSV.generate_line(PHOTOS_TRIPS_EXPORTS.collect {|e| e[0]}))
    f.write("\r\n")

    user.trip_photos.find_each do |photo|
      f.write(CSV.generate_line(
        PHOTOS_TRIPS_EXPORTS.collect do |e|
          if e.length == 1 then
            photo.send(e[0])
          else
            e[1].call(photo)
          end
        end
      ))
      f.write("\r\n")

      # and copy the photo
      system("ln", photo.photo.path, "trip-#{photo.id}-#{photo.photo_file_name}")
    end
  end
end
