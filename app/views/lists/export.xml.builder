xml_sighting_fields = [:date_day, :date_month, :date_year, :species_count, :juvenile_male, :juvenile_female, :juvenile_unknown, :immature_male, :immature_female, :immature_unknown, :adult_male, :adult_female, :adult_unknown, :unknown_male, :unknown_female, :unknown_unknown, :notes, :time_hour, :time_minute, :private, :tag_list, :link]

xml_location_fields = [:cc, :adm1, :adm2, :location, :name, :notes, :latitude, :longitude, :zoom, :source, :ecoregion, :elevation_ft, :elevation_m, :private]

xml_trip_fields = [:name, :description, :time_hour_start, :time_minute_start, :protocol, :number_observers, :duration_hours, :duration_minutes, :distance_traveled_mi, :distance_traveled_km, :area_covered_acres, :area_covered_sqmi, :area_covered_sqkm, :date_day_start, :date_month_start, :date_year_start, :all_observations_reported, :date_day_end, :date_month_end, :date_year_end, :private]

xml.instruct!
xml.birdstack do
	@sightings.each do |sighting|
		xml.observation do
			xml.species do
				xml.order sighting.species.genus.family.order.latin_name
				xml.family_latin sighting.species.genus.family.latin_name
				xml.family_english sighting.species.genus.family.english_name
				xml.genus sighting.species.genus.latin_name
				xml.species_latin sighting.species.latin_name
				xml.species_english sighting.species.english_name
			end
			xml_sighting_fields.each do |field|
				xml.tag!(field, sighting.send(field)) if !sighting.send(field).blank?
			end
			if sighting.user_location then
				xml.location do
					xml_location_fields.each do |field|
						xml.tag!(field, sighting.user_location.send(field)) if !sighting.user_location.send(field).blank?
					end
				end
			end
			if sighting.trip then
				xml.trip do
					xml_trip_fields.each do |field|
						xml.tag!(field, sighting.trip.send(field)) if !sighting.trip.send(field).blank?
					end
				end
			end
		end
	end
end
